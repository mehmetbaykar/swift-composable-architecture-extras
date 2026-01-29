enum FirebaseTestEvent: Sendable, Equatable {
  case screenView(screenName: String, screenClass: String?)
  case login(method: String)
  case signUp(method: String)
  case purchase(value: Double, currency: String, itemId: String)
  case selectContent(contentType: String, itemId: String)
}
