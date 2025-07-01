public enum Currency: String, CaseIterable, Codable, Equatable, Sendable {
  case cny, chf, rub, usd, eur, gbp

  public var key: String {
    self.rawValue.uppercased()
  }
}
