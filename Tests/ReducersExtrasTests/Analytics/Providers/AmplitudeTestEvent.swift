enum AmplitudeTestEvent: Sendable, Equatable {
  case screenViewed(screenName: String)
  case buttonClicked(buttonId: String)
  case signUpCompleted(method: String)
  case purchaseCompleted(revenue: Double, productId: String)
  case featureUsed(featureName: String)
}
