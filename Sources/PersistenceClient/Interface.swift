import Dependencies
import DependenciesMacros
import Foundation
import Model

extension DependencyValues {
  public var persistenceClient: PersistenceClient {
    get { self[PersistenceClient.self] }
    set { self[PersistenceClient.self] = newValue }
  }
}

@DependencyClient
public struct PersistenceClient: Sendable {
  public var fetchCachedRates: @Sendable () async throws -> [String: ExchangeRate]
  public var fetchCachedRate: @Sendable (Currency) async throws -> ExchangeRate?

  public var cacheRates: @Sendable (ExchangeRate) async throws -> Void

  public var fetchConversionsHistory: @Sendable () async throws -> [Conversion]
  public var saveConversion: @Sendable (Conversion) async throws -> Void

  public var fetchLastConversionPair: @Sendable () async -> (Currency, Currency)?
  public var saveConversionPair: @Sendable (Currency, Currency) async throws -> Void

  public enum PersistenceError: Error, Equatable, LocalizedError {
    case dataCorrupted
    case storageFailure

    public var errorDescription: String? {
      switch self {
      case .dataCorrupted:
        "Data corrupted"
      case .storageFailure:
        "Failed to load data from storage"
      }
    }
  }
}
