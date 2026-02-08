import Darwin
import Foundation

#if os(watchOS)
  enum CPUMeasurement {
    static func measure() async -> CPUInfo {
      let sample1 = taskCPUTime()
      let wallStart = DispatchTime.now()
      try? await Task.sleep(nanoseconds: 100_000_000)
      let sample2 = taskCPUTime()
      let wallEnd = DispatchTime.now()

      let cpuDelta = sample2 - sample1
      let wallDelta =
        Double(wallEnd.uptimeNanoseconds - wallStart.uptimeNanoseconds) / 1_000_000_000

      guard wallDelta > 0 else { return .zero }

      let usage = min(cpuDelta / wallDelta, 1.0)
      return CPUInfo(
        usage: Percentage(rawValue: usage),
        user: Percentage(rawValue: usage),
        system: .zero,
        idle: Percentage(rawValue: max(1.0 - usage, 0))
      )
    }

    private static func taskCPUTime() -> Double {
      var info = task_thread_times_info_data_t()
      var count = mach_msg_type_number_t(
        MemoryLayout<task_thread_times_info_data_t>.size / MemoryLayout<natural_t>.size
      )
      let result = withUnsafeMutablePointer(to: &info) { pointer in
        pointer.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { pointer in
          task_info(mach_task_self_, task_flavor_t(TASK_THREAD_TIMES_INFO), pointer, &count)
        }
      }
      guard result == KERN_SUCCESS else { return 0 }

      let userTime =
        Double(info.user_time.seconds) + Double(info.user_time.microseconds) / 1_000_000
      let systemTime =
        Double(info.system_time.seconds) + Double(info.system_time.microseconds) / 1_000_000
      return userTime + systemTime
    }
  }

#else
  enum CPUMeasurement {
    static func measure() async -> CPUInfo {
      let first = hostCPULoadInfo()
      try? await Task.sleep(nanoseconds: 100_000_000)
      let second = hostCPULoadInfo()

      let userDiff = Double(second.cpu_ticks.0 - first.cpu_ticks.0)
      let systemDiff = Double(second.cpu_ticks.1 - first.cpu_ticks.1)
      let idleDiff = Double(second.cpu_ticks.2 - first.cpu_ticks.2)
      let niceDiff = Double(second.cpu_ticks.3 - first.cpu_ticks.3)
      let totalTicks = userDiff + systemDiff + idleDiff + niceDiff

      guard totalTicks > 0 else { return .zero }

      let user = userDiff / totalTicks
      let system = systemDiff / totalTicks
      let idle = idleDiff / totalTicks
      let usage = min(user + system, 1.0)

      return CPUInfo(
        usage: Percentage(rawValue: usage),
        user: Percentage(rawValue: user),
        system: Percentage(rawValue: system),
        idle: Percentage(rawValue: idle)
      )
    }

    private static func hostCPULoadInfo() -> host_cpu_load_info {
      var size = mach_msg_type_number_t(
        MemoryLayout<host_cpu_load_info_data_t>.size / MemoryLayout<integer_t>.size
      )
      let hostInfo = host_cpu_load_info_t.allocate(capacity: 1)
      let result = hostInfo.withMemoryRebound(to: integer_t.self, capacity: Int(size)) { pointer in
        host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, pointer, &size)
      }
      let data: host_cpu_load_info
      if result == KERN_SUCCESS {
        data = hostInfo.move()
      } else {
        data = host_cpu_load_info()
      }
      hostInfo.deallocate()
      return data
    }
  }
#endif
