import Model
import Foundation

extension PersistenceClient {
  public static let live: PersistenceClient = {
    let impl = PersistenceClientImpl()

    return Self(
      fetchCachedRates: {
        try await impl.fetchCachedRates()
      },
      fetchCachedRate: {
        try await impl.fetchCachedRate(for: $0)
      },
      cacheRates: {
        try await impl.cacheRates($0)
      },
      fetchConversionsHistory: {
        try await impl.fetchConversionsHistory()
      },
      saveConversion: {
        try await impl.saveConversion($0)
      },
      fetchLastConversionPair: {
        impl.fetchLastConversionPair()
      },
      saveConversionPair: {
        try await impl.saveConversionPair(source: $0, target: $1)
      }
    )
  }()
}

private final class PersistenceClientImpl {

  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()
  private let storage = UserDefaults.standard
  private let cacheMaxAge: TimeInterval = 7200

  func fetchCachedRates() async throws -> [String: ExchangeRate] {
    guard let data = storage.data(forKey: .cachedRates) else {
      return [:]
    }
    print("fetchCachedRates(), \(data)")
    return try decoder.decode([String: ExchangeRate].self, from: data)
  }

  func cacheRates(_ rate: ExchangeRate) async throws {
    var allRates = try await fetchCachedRates()
    let sourceKey = rate.source.key
    if let existing = allRates[sourceKey], isCachedRateValid(existing) {
      allRates[sourceKey] = rate
    } else {
      allRates[sourceKey] = rate
    }
    print("cacheRates(), \(allRates)")

    let data = try encoder.encode(allRates)
    storage.set(data, forKey: .cachedRates)
  }

  func fetchCachedRate(for source: Currency) async throws -> ExchangeRate? {
    let allRates = try await fetchCachedRates()
    let rate = allRates[source.key]
    if let rate, isCachedRateValid(rate) {
      print("fetchCachedRate(), cache rate fetched")
      return rate
    }
    print("fetchCachedRate(), cache rate expired")
    return nil
  }

  func fetchLastConversionPair() -> (Currency, Currency)? {
    guard let data = storage.data(forKey: .lastConversionPair),
          let pair = try? decoder.decode([Currency].self, from: data),
          pair.count == 2 else {
      return nil
    }

    return (pair[0], pair[1])
  }

  func fetchConversionsHistory() async throws -> [Conversion] {
    guard let data = storage.data(forKey: .conversionsHistory) else {
      return []
    }
    return try decoder.decode([Conversion].self, from: data)
  }

  func saveConversion(_ conversion: Conversion) async throws {
    var conversions = try await fetchConversionsHistory()
    conversions.insert(conversion, at: 0)
    let data = try encoder.encode(conversions)
    storage.set(data, forKey: .conversionsHistory)
  }

  func saveConversionPair(source: Currency, target: Currency) async throws {
    let data = try encoder.encode([source, target])
    storage.set(data, forKey: .lastConversionPair)
  }

  private func isCachedRateValid(_ rate: ExchangeRate) -> Bool {
    Date().timeIntervalSince(rate.timestamp) < cacheMaxAge
  }
}

private extension String {
  static let cachedRates = "cachedExchangeRates"
  static let conversionsHistory = "conversionsHistory"
  static let lastConversionPair = "lastConversionPair"
}
