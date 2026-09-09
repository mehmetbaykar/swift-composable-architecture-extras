#if os(iOS)

  import AVFoundation
  import ExternalAccessory

  enum AccessoryMeasurement {
    @MainActor
    static func measure() -> AccessoryInfo {
      AccessoryInfo(
        isHeadphonesConnected: isHeadphonesConnected(),
        connectedAccessories: connectedAccessoryNames()
      )
    }

    @MainActor
    private static func isHeadphonesConnected() -> Bool {
      let headphonePorts: Set<AVAudioSession.Port> = [
        .headphones, .bluetoothA2DP, .bluetoothHFP, .bluetoothLE,
      ]
      return AVAudioSession.sharedInstance().currentRoute.outputs.contains {
        headphonePorts.contains($0.portType)
      }
    }

    @MainActor
    private static func connectedAccessoryNames() -> [String] {
      EAAccessoryManager.shared().connectedAccessories.map { accessory in
        if !accessory.name.isEmpty { return accessory.name }
        if !accessory.manufacturer.isEmpty { return accessory.manufacturer }
        return "Unknown"
      }
    }
  }

#endif
