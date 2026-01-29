## Analytics

A generic analytics module for TCA that handles provider integration and reducer composition.

## Quick Start

```swift
// 1. Define events
enum AppEvent: Sendable { case screenViewed(name: String) }

// 2. Create provider
extension AnalyticsClient where Event == AppEvent {
  static var myProvider: Self { .init { event in print("Track: \(event)") } }
}

// 3. Use in reducer
AnalyticsReducerOf<Self, AppEvent> { state, action in
  action == .viewAppeared ? .screenViewed(name: "Home") : nil
}
```

## Define Your Events

```swift
enum AppEvent: Sendable {
  case screenViewed(name: String)
  case login(method: String)
  case signUp(method: String)
  case purchase(productId: String, amount: Decimal)
  case featureUsed(name: String)
  case buttonClicked(id: String)
}
```

## Firebase Provider

```swift
import ComposableArchitectureExtras
import FirebaseAnalytics

extension AnalyticsClient where Event == AppEvent {
  static var firebase: Self {
    .init { event in
      switch event {
      case .screenViewed(let name):
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [AnalyticsParameterScreenName: name])
      case .login(let method):
        Analytics.logEvent(AnalyticsEventLogin, parameters: [AnalyticsParameterMethod: method])
      case .signUp(let method):
        Analytics.logEvent(AnalyticsEventSignUp, parameters: [AnalyticsParameterMethod: method])
      case .purchase(let productId, let amount):
        Analytics.logEvent(AnalyticsEventPurchase, parameters: [
          AnalyticsParameterItemID: productId, AnalyticsParameterValue: amount
        ])
      case .featureUsed(let name):
        Analytics.logEvent("feature_used", parameters: ["feature_name": name])
      case .buttonClicked(let id):
        Analytics.logEvent("button_clicked", parameters: ["button_id": id])
      }
    }
  }
}
```

## Amplitude Provider

```swift
import ComposableArchitectureExtras
import AmplitudeSwift

extension AnalyticsClient where Event == AppEvent {
  static var amplitude: Self {
    let client = Amplitude(configuration: Configuration(apiKey: "YOUR_API_KEY"))
    return .init { event in
      switch event {
      case .screenViewed(let name):
        client.track(eventType: "Screen Viewed", eventProperties: ["screen_name": name])
      case .login(let method):
        client.track(eventType: "User Logged In", eventProperties: ["method": method])
      case .signUp(let method):
        client.track(eventType: "User Signed Up", eventProperties: ["method": method])
      case .purchase(let productId, let amount):
        client.track(eventType: "Purchase Completed", eventProperties: [
          "product_id": productId, "amount": amount
        ])
      case .featureUsed(let name):
        client.track(eventType: "Feature Used", eventProperties: ["feature_name": name])
      case .buttonClicked(let id):
        client.track(eventType: "Button Clicked", eventProperties: ["button_id": id])
      }
    }
  }
}
```

## Using Reducers

### AnalyticsReducerOf

Track events based on actions using the `AnalyticsReducerOf<Self, Event>` typealias:

```swift
import ComposableArchitecture
import ComposableArchitectureExtras

@Reducer
struct FeatureReducer {
  @ObservableState
  struct State: Equatable {
    var isLoggedIn = false
    var screenName = "Feature"
  }

  enum Action {
    case viewAppeared
    case loginTapped
    case logoutTapped
  }

  var body: some ReducerOf<Self> {
    AnalyticsReducerOf<Self, AppEvent> { state, action in
      switch action {
      case .viewAppeared: return .screenViewed(name: state.screenName)
      case .loginTapped: return .login(method: "email")
      case .logoutTapped: return nil
      }
    }
    Reduce { state, action in
      switch action {
      case .viewAppeared:
        return .none
      case .loginTapped:
        state.isLoggedIn = true
        return .none
      case .logoutTapped:
        state.isLoggedIn = false
        return .none
      }
    }
  }
}
```

### Multiple Events

Return an array when a single action should track multiple events:

```swift
AnalyticsReducerOf<Self, AppEvent> { state, action in
  switch action {
  case .checkoutCompleted:
    return [
      .buttonClicked(id: "checkout_complete"),
      .purchase(productId: state.productId, amount: state.total)
    ]
  case .viewAppeared: return .screenViewed(name: "Checkout")
  default: return nil
  }
}
```

### analyticsOnChange

Track events when state values change:

```swift
@Reducer
struct CartReducer {
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      // Cart logic
    }
    .analyticsOnChange(of: \.itemCount) { oldCount, newCount in
      newCount > oldCount ? .featureUsed(name: "cart_item_added") : .featureUsed(name: "cart_item_removed")
    }
  }
}
```

Multiple events can also be returned:

```swift
.analyticsOnChange(of: \.cartTotal) { oldTotal, newTotal in
  [.featureUsed(name: "cart_updated"), .purchase(productId: "cart", amount: newTotal)]
}
```

## Register with TCA

```swift
@main
struct MyApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView(
        store: Store(initialState: AppReducer.State()) {
          AppReducer()
        } withDependencies: {
          $0.analyticsClient = AnyAnalyticsClient(
            AnalyticsClient<AppEvent>.merge(.firebase, .amplitude, .consoleLogger())
          )
        }
      )
    }
  }
}
```

## Built-in Providers

- `consoleLogger()` – Prints events in DEBUG builds
- `noop()` – Discards all events
- `merge(...)` – Combines multiple clients
