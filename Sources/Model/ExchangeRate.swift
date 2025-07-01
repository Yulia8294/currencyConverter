import Foundation

public struct ExchangeRate: Equatable, Codable, Sendable {
  public let source: Currency
  public let rates: [String: Double]
  public let timestamp: Date

  public init(source: Currency, rates: [String : Double], timestamp: Date) {
    self.source = source
    self.rates = rates
    self.timestamp = timestamp
  }
}
