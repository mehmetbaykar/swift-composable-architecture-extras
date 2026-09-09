import Darwin
import Foundation

enum HardwareIdentifier {
  static func modelIdentifier() -> String {
    if let simulator = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"],
      !simulator.isEmpty
    {
      return simulator
    }

    #if os(macOS)
      var size = 0
      sysctlbyname("hw.model", nil, &size, nil, 0)
      guard size > 0 else { return machineFromUname() }
      var model = [CChar](repeating: 0, count: size)
      sysctlbyname("hw.model", &model, &size, nil, 0)
      return String(cString: model)
    #else
      return machineFromUname()
    #endif
  }

  private static func machineFromUname() -> String {
    var systemInfo = utsname()
    uname(&systemInfo)
    return withUnsafePointer(to: &systemInfo.machine) {
      $0.withMemoryRebound(to: CChar.self, capacity: 1) {
        String(validatingCString: $0) ?? ""
      }
    }
  }
}
