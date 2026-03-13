# LoggerClient

A composable logging dependency for TCA applications with multiple destinations.

## Overview

`AppLoggerClient` provides a testable, composable logging interface following the same `merge()` pattern as `AnalyticsClient`. Compose console, file, and custom log destinations into a single dependency.

## Setup

Configure the logger at app startup via `prepareDependencies`. Without setup, accessing the dependency triggers an `unimplemented()` warning (no `liveValue`).

```swift
@main
struct MyApp: App {
  init() {
    prepareDependencies {
      $0.loggerClient = .merge(
        .console(),
        .fileLogger()
      )
    }
  }
}
```

## Usage

```swift
@Dependency(\.loggerClient) var logger

logger.debug("Cache hit for key: \(key)")
logger.info("User logged in")
logger.notice("Configuration loaded")
logger.error("Network request failed: \(error)")
logger.fault("Unrecoverable state corruption")
```

## Built-in Destinations

### Console — `.console(formatter:)`

Logs to Apple's `os.Logger` (visible in Console.app and Instruments). Auto-detects subsystem from `Bundle.main.bundleIdentifier`.

```swift
.console()
.console(formatter: MyCustomFormatter())
```

### File — `.fileLogger(filename:directory:maxFileSize:maxFiles:formatter:)`

Writes to disk via an actor for thread-safe I/O. Supports size-based rotation.

```swift
// Zero config (Library/Caches/Logs/app.log, 5MB max, 3 files):
.fileLogger()

// Full config:
.fileLogger(
  filename: "myapp.log",
  directory: customURL,
  maxFileSize: 10_000_000,
  maxFiles: 5,
  formatter: MyCustomFormatter()
)
```

### No-Op — `.noop()`

Discards all log entries silently.

### Merge — `.merge(_ clients:)`

Composes multiple destinations. Every log entry fans out to all clients.

```swift
.merge(.console(), .fileLogger(), .crashlytics())
```

## Custom Formatter

Implement the `LogFormatter` protocol to customize log output format:

```swift
struct JSONFormatter: LogFormatter {
  func format(_ entry: LogEntry) -> String {
    "{\"ts\":\"\(entry.timestamp)\",\"level\":\"\(entry.level)\",\"msg\":\"\(entry.message)\"}"
  }
}
```

The default `PlainTextFormatter` produces pipe-separated structured output:

```
2026-03-11 12:30:45.123 | INFO  | LoginView.swift:28 | viewAppeared() | User logged in
```

## Custom Destinations

Create any custom destination by implementing `AppLoggerClient.init(log:)` and mapping `LogEntry.level` to the platform's log levels.

### Firebase Crashlytics

```swift
import FirebaseCrashlytics

extension AppLoggerClient {
  static func crashlytics() -> Self {
    .init { entry in
      Crashlytics.crashlytics().log("\(entry.message)")

      if entry.level == .error || entry.level == .fault {
        let error = NSError(
          domain: "AppLogger",
          code: entry.level == .fault ? 1 : 0,
          userInfo: [NSDebugDescriptionErrorKey: entry.message]
        )
        Crashlytics.crashlytics().record(error: error)
      }
    }
  }
}
```

### Sentry

```swift
import Sentry

extension AppLoggerClient {
  static func sentry() -> Self {
    .init { entry in
      let breadcrumb = Breadcrumb(level: entry.sentryLevel, category: "app")
      breadcrumb.message = entry.message
      SentrySDK.addBreadcrumb(breadcrumb)

      if entry.level == .error || entry.level == .fault {
        SentrySDK.capture(message: entry.message)
      }
    }
  }
}

private extension LogEntry {
  var sentryLevel: SentryLevel {
    switch level {
    case .debug: .debug
    case .info: .info
    case .error: .error
    case .fault: .fatal
    default: .info
    }
  }
}
```

### Datadog

```swift
import DatadogLogs

extension AppLoggerClient {
  static func datadog() -> Self {
    let logger = Logger.create(
      with: Logger.Configuration(name: "app", remoteLogThreshold: .info)
    )
    return .init { entry in
      switch entry.level {
      case .debug:   logger.debug(entry.message)
      case .info:    logger.info(entry.message)
      case .default: logger.notice(entry.message)
      case .error:   logger.error(entry.message)
      case .fault:   logger.critical(entry.message)
      default:       logger.info(entry.message)
      }
    }
  }
}
```

### Composing Everything Together

```swift
prepareDependencies {
  $0.loggerClient = .merge(
    .console(),        // os.Logger (Console.app)
    .fileLogger(),     // local file (debugging)
    .sentry(),         // breadcrumbs + error events
    .crashlytics(),    // crash report context + non-fatals
    .datadog()         // remote log aggregation
  )
}

// One call fans out to ALL 5 destinations:
@Dependency(\.loggerClient) var logger
logger.error("Payment failed: \(error)")
```

## Log Levels

Maps directly to `OSLogType`:

| Method     | OSLogType  |
|------------|------------|
| `debug()`  | `.debug`   |
| `info()`   | `.info`    |
| `notice()` | `.default` |
| `error()`  | `.error`   |
| `fault()`  | `.fault`   |

## Platform Support

All platforms: iOS, macOS, tvOS, watchOS.
