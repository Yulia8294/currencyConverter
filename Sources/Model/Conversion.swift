import Foundation

public struct Conversion: Codable, Equatable, Identifiable, Sendable {
  public let id: UUID
  public let date: Date
  public let source: Currency
  public let target: Currency
  public let sourceValue: Double
  public let targetValue: Double
  public let exchangeRate: Double

  public init(
    id: UUID,
    date: Date,
    source: Currency,
    target: Currency,
    sourceValue: Double,
    targetValue: Double,
    exchangeRate: Double
  ) {
    self.id = id
    self.date = date
    self.source = source
    self.target = target
    self.sourceValue = sourceValue
    self.targetValue = targetValue
    self.exchangeRate = exchangeRate
  }
}
