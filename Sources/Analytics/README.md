## Analytics

A generic analytics module for TCA that handles provider integration and reducer composition using a declarative result builder syntax.

## Quick Start

```swift
enum AppEvent: Sendable { case screenViewed(name: String) }

extension AnalyticsClient where Event == AppEvent {
  static var myProvider: Self { .init { event in print("Track: \(event)") } }
}

AnalyticsReducerOf<Self, AppEvent> { state, action in
  switch action {
  case .viewAppeared: .screenViewed(name: "Home")
  case .dismissed: []
  }
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

## Result Builder Syntax

The `@AnalyticsEventBuilder` supports all standard Swift control flow.

### Single Event

```swift
case .viewAppeared:
  .screenViewed(name: state.screenName)
```

### No Event

```swift
case .dismissed:
  []
```

### Multiple Events

Use explicit type on separate lines:

```swift
case .checkoutCompleted:
  AppEvent.buttonClicked(id: "checkout")
  AppEvent.purchase(productId: state.productId, amount: state.total)
```

Or use array literal:

```swift
case .checkoutCompleted:
  [.buttonClicked(id: "checkout"), .purchase(productId: state.productId, amount: state.total)]
```

### Conditional

```swift
case .logoutTapped:
  if state.hasActiveSubscription {
    .featureUsed(name: "subscriber_logout")
  }
```

### If-Else

```swift
case .purchaseTapped:
  if state.isFirstPurchase {
    .featureUsed(name: "first_purchase")
  } else {
    .featureUsed(name: "repeat_purchase")
  }
```

### Loops

```swift
case .itemsAdded(let items):
  for item in items {
    .featureUsed(name: "item_added_\(item.id)")
  }
```

## State Change Tracking

Track events when state values change with `analyticsOnChange`:

```swift
Reduce { state, action in
  // Business logic
}
.analyticsOnChange(of: \.itemCount) { oldCount, newCount in
  if newCount > oldCount {
    .featureUsed(name: "item_added")
  } else {
    .featureUsed(name: "item_removed")
  }
}
```

## Full Example

```swift
@Reducer
struct CartReducer {
  @ObservableState
  struct State: Equatable {
    var items: [Item] = []
    var hasActiveSubscription = false
    var productId = ""
    var total: Decimal = 0
  }

  enum Action {
    case viewAppeared
    case loginTapped
    case signUpTapped
    case checkoutCompleted
    case itemsAdded([Item])
    case logoutTapped
  }

  var body: some ReducerOf<Self> {
    AnalyticsReducerOf<Self, AppEvent> { state, action in
      switch action {
      case .viewAppeared:
        .screenViewed(name: "Cart")
      case .loginTapped:
        .login(method: "email")
      case .signUpTapped:
        .signUp(method: "email")
      case .checkoutCompleted:
        AppEvent.buttonClicked(id: "checkout")
        AppEvent.purchase(productId: state.productId, amount: state.total)
      case .itemsAdded(let items):
        for item in items {
          .featureUsed(name: "item_added_\(item.id)")
        }
      case .logoutTapped:
        if state.hasActiveSubscription {
          .featureUsed(name: "subscriber_logout")
        } else {
          []
        }
      }
    }

    Reduce { state, action in
      switch action {
      case .viewAppeared, .loginTapped, .signUpTapped, .checkoutCompleted, .logoutTapped:
        return .none
      case .itemsAdded(let items):
        state.items.append(contentsOf: items)
        return .none
      }
    }
    .analyticsOnChange(of: \.items.count) { old, new in
      if new > old {
        .featureUsed(name: "cart_item_added")
      } else if new < old {
        .featureUsed(name: "cart_item_removed")
      } else {
        []
      }
    }
  }
}
```

## Example Provider Implementations

### Firebase

```swift
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

### Amplitude

```swift
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
        client.track(eventType: "Purchase", eventProperties: ["product_id": productId, "amount": amount])
      case .featureUsed(let name):
        client.track(eventType: "Feature Used", eventProperties: ["feature_name": name])
      case .buttonClicked(let id):
        client.track(eventType: "Button Clicked", eventProperties: ["button_id": id])
      }
    }
  }
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
