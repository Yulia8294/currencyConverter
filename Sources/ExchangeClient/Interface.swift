import Dependencies
import DependenciesMacros
import Foundation
import Model

extension DependencyValues {
  public var exchangeClient: ExchangeClient {
    get { self[ExchangeClient.self] }
    set { self[ExchangeClient.self] = newValue }
  }
}

@DependencyClient
public struct ExchangeClient: Sendable {

  public var initialize: @Sendable () throws -> Void
  public var convert: @Sendable (ConvertRequest) async throws -> Conversion

  public enum ExchangeError: Error, Equatable, LocalizedError {
    case exchangeRateNotFound
    case apiKeyMissing
    case invalidRequest(reason: String)
    case decodingError(underlying: String)
    case networkError(description: String)

    public var errorDescription: String? {
      switch self {
      case .exchangeRateNotFound:
        return "The requested exchange rate could not be found."
      case .decodingError(let description):
        return "Failed to decode the response: \(description)"
      case .networkError(let description):
        return "Network error: \(description)"
      case .invalidRequest(let reason):
        return "Invalid conversion request: \(reason)"
      case .apiKeyMissing:
        return "Api key is missing or invalid"
      }
    }
  }
}

public struct ConvertRequest {
  public let source: Currency
  public let target: Currency
  public let amount: Double

  public init(source: Currency, target: Currency, amount: Double) {
    self.source = source
    self.target = target
    self.amount = amount
  }
}
