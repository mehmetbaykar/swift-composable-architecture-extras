import Darwin
import Foundation

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
