import Darwin
import Foundation

#if os(watchOS)
  enum MemoryMeasurement {
    static func measure() -> MemoryInfo {
      let total = Int64(ProcessInfo.processInfo.physicalMemory)
      let available = Int64(os_proc_available_memory())
      let used = max(total - available, 0)

      let usage: Double
      if total > 0 {
        usage = Double(used) / Double(total)
      } else {
        usage = 0
      }

      return MemoryInfo(
        usage: Percentage(rawValue: min(usage, 1.0)),
        total: ByteCount(bytes: total),
        used: ByteCount(bytes: used),
        available: ByteCount(bytes: available)
      )
    }
  }
#else
  enum MemoryMeasurement {
    static func measure() -> MemoryInfo {
      let total = Int64(ProcessInfo.processInfo.physicalMemory)
      let statistics = vmStatistics64()
      let pageSize = Int64(vmPageSize())

      let active = Int64(statistics.active_count) * pageSize
      let inactive = Int64(statistics.inactive_count) * pageSize
      let speculative = Int64(statistics.speculative_count) * pageSize
      let wired = Int64(statistics.wire_count) * pageSize
      let compressed = Int64(statistics.compressor_page_count) * pageSize
      let purgeable = Int64(statistics.purgeable_count) * pageSize
      let external = Int64(statistics.external_page_count) * pageSize

      let cached = purgeable + external
      let app = active + inactive + speculative - cached
      let pressure = wired + compressed
      let used = app + pressure
      let available = max(total - used, 0)

      let usage: Double
      if total > 0 {
        usage = min(Double(used) / Double(total), 1.0)
      } else {
        usage = 0
      }

      return MemoryInfo(
        usage: Percentage(rawValue: usage),
        total: ByteCount(bytes: total),
        used: ByteCount(bytes: used),
        available: ByteCount(bytes: available)
      )
    }

    private static func vmStatistics64() -> vm_statistics64 {
      var size = mach_msg_type_number_t(
        MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size
      )
      var statistics = Darwin.vm_statistics64()
      _ = withUnsafeMutablePointer(to: &statistics) { pointer in
        pointer.withMemoryRebound(to: integer_t.self, capacity: Int(size)) { pointer in
          host_statistics64(mach_host_self(), HOST_VM_INFO64, pointer, &size)
        }
      }
      return statistics
    }

    private static func vmPageSize() -> vm_size_t {
      var size = vm_size_t()
      host_page_size(mach_host_self(), &size)
      return size
    }
  }
#endif
