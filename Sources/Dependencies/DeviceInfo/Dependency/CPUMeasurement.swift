import Darwin
import Foundation

enum CPUMeasurement {
  static func measure() async -> CPUInfo {
    let first = hostCPULoadInfo()
    let firstPerCore = processorLoadInfo()
    try? await Task.sleep(nanoseconds: 100_000_000)
    let second = hostCPULoadInfo()
    let secondPerCore = processorLoadInfo()

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
      idle: Percentage(rawValue: idle),
      perCoreUsage: perCoreUsage(first: firstPerCore, second: secondPerCore)
    )
  }

  private static func perCoreUsage(
    first: [(user: Int32, system: Int32, idle: Int32, nice: Int32)],
    second: [(user: Int32, system: Int32, idle: Int32, nice: Int32)]
  ) -> [Percentage] {
    guard first.count == second.count, !first.isEmpty else { return [] }
    return zip(first, second).map { start, end in
      let user = Double(end.user - start.user)
      let system = Double(end.system - start.system)
      let idle = Double(end.idle - start.idle)
      let nice = Double(end.nice - start.nice)
      let total = user + system + idle + nice
      guard total > 0 else { return .zero }
      return Percentage(rawValue: min((user + system + nice) / total, 1.0))
    }
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

  private static func processorLoadInfo() -> [(
    user: Int32, system: Int32, idle: Int32, nice: Int32
  )] {
    var cpuCount: natural_t = 0
    var cpuInfo: processor_info_array_t?
    var cpuInfoCount: mach_msg_type_number_t = 0
    let result = host_processor_info(
      mach_host_self(),
      PROCESSOR_CPU_LOAD_INFO,
      &cpuCount,
      &cpuInfo,
      &cpuInfoCount
    )
    guard result == KERN_SUCCESS, let cpuInfo else { return [] }
    defer {
      let size = vm_size_t(cpuInfoCount) * vm_size_t(MemoryLayout<integer_t>.stride)
      vm_deallocate(mach_task_self_, vm_address_t(bitPattern: cpuInfo), size)
    }

    var ticks: [(user: Int32, system: Int32, idle: Int32, nice: Int32)] = []
    ticks.reserveCapacity(Int(cpuCount))
    for index in 0..<Int(cpuCount) {
      let base = index * Int(CPU_STATE_MAX)
      ticks.append(
        (
          user: cpuInfo[base + Int(CPU_STATE_USER)],
          system: cpuInfo[base + Int(CPU_STATE_SYSTEM)],
          idle: cpuInfo[base + Int(CPU_STATE_IDLE)],
          nice: cpuInfo[base + Int(CPU_STATE_NICE)]
        )
      )
    }
    return ticks
  }
}
