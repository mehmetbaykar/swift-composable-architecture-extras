# AppInfo

A lightweight TCA dependency for accessing app bundle information.

## Overview

`AppInfoClient` provides a testable interface for reading app metadata from `Bundle.main`, including version strings, build numbers, and bundle identifiers.

## Usage

### Access in a Reducer

```swift
@Reducer
struct MyFeature {
  @ObservableState
  struct State: Equatable {
    var displayVersion: String = ""
  }

  enum Action {
    case onAppear
  }

  @Dependency(\.appInfo) var appInfo

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        let version = appInfo.appVersion()
        let build = appInfo.buildNumber()
        state.displayVersion = "\(version) (\(build))"
        return .none
      }
    }
  }
}
```

### Testing

```swift
let store = TestStore(initialState: MyFeature.State()) {
  MyFeature()
} withDependencies: {
  $0.appInfo = AppInfoClient(
    appVersion: { "2.0.0" },
    buildNumber: { "42" },
    bundleIdentifier: { "com.example.app" }
  )
}
```

## API

| Property | Type | Description |
|----------|------|-------------|
| `appVersion` | `@Sendable () -> String` | `CFBundleShortVersionString` (e.g. "1.2.3") |
| `buildNumber` | `@Sendable () -> String` | `CFBundleVersion` (e.g. "42") |
| `bundleIdentifier` | `@Sendable () -> String?` | `Bundle.main.bundleIdentifier` |
