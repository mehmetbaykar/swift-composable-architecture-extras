import Foundation

public enum DeviceThermalState: Sendable, Equatable {
  case nominal
  case fair
  case serious
  case critical
}

extension DeviceThermalState {
  init(processInfoState: ProcessInfo.ThermalState) {
    switch processInfoState {
    case .nominal: self = .nominal
    case .fair: self = .fair
    case .serious: self = .serious
    case .critical: self = .critical
    @unknown default: self = .nominal
    }
  }
}
