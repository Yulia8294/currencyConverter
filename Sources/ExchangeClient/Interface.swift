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

  public var initialize: @Sendable () -> Void
  public var convert: @Sendable (ConvertRequest) async throws -> Conversion

  public enum ExchangeError: Error, Equatable, LocalizedError {
    case exchangeRateNotFound
    case decodingError
    case networkError(description: String)
    case invalidRequest

    public var errorDescription: String? {
      switch self {
      case .exchangeRateNotFound:
        return "The requested exchange rate could not be found."
      case .decodingError:
        return "Failed to decode the response."
      case .networkError(let description):
        return "Network error: \(description)"
      case .invalidRequest:
        return "Invalid conversion request."
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
