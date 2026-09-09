import Darwin
import Foundation

enum ProcessMeasurement {
  static func measure() -> ProcessMetrics {
    ProcessMetrics(processID: getpid(), cpuUsage: cpuUsage())
  }

  private static func cpuUsage() -> Percentage {
    var threadList: thread_act_array_t?
    var threadCount: mach_msg_type_number_t = 0
    guard task_threads(mach_task_self_, &threadList, &threadCount) == KERN_SUCCESS,
      let threadList
    else {
      return .zero
    }
    defer {
      let size = vm_size_t(threadCount) * vm_size_t(MemoryLayout<thread_t>.stride)
      vm_deallocate(mach_task_self_, vm_address_t(bitPattern: threadList), size)
    }

    var total: Double = 0
    for index in 0..<Int(threadCount) {
      var info = thread_basic_info()
      var count = mach_msg_type_number_t(THREAD_INFO_MAX)
      let result = withUnsafeMutablePointer(to: &info) { pointer in
        pointer.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { rebound in
          thread_info(threadList[index], thread_flavor_t(THREAD_BASIC_INFO), rebound, &count)
        }
      }
      guard result == KERN_SUCCESS else { continue }
      if info.flags & TH_FLAGS_IDLE == 0 {
        total += Double(info.cpu_usage) / Double(TH_USAGE_SCALE)
      }
    }
    return Percentage(rawValue: total)
  }
}
