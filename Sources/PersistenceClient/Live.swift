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
        await impl.fetchLastConversionPair()
      },
      saveConversionPair: {
        try await impl.saveConversionPair(source: $0, target: $1)
      }
    )
  }()
}

private final actor PersistenceClientImpl {
  private let encoder: JSONEncoder
  private let decoder: JSONDecoder
  private let storage: UserDefaults
  private let cacheMaxAge: TimeInterval

  init(
    encoder: JSONEncoder = JSONEncoder(),
    decoder: JSONDecoder = JSONDecoder(),
    cacheMaxAge: TimeInterval = 7200
  ) {
    self.encoder = encoder
    self.decoder = decoder
    self.cacheMaxAge = cacheMaxAge
    self.storage = UserDefaults.standard
  }

  func fetchCachedRates() async throws -> [String: ExchangeRate] {
    guard let data = storage.data(forKey: .cachedRates) else {
      return [:]
    }

    do {
      return try decoder.decode([String: ExchangeRate].self, from: data)
    } catch {
      storage.removeObject(forKey: .cachedRates)
      throw PersistenceClient.PersistenceError.dataCorrupted
    }
  }

  func cacheRates(_ rate: ExchangeRate) async throws {
    var allRates = try await fetchCachedRates()
    let currentRate = allRates[rate.source.key]

    if currentRate == nil || !isRateValid(currentRate!) {
      allRates[rate.source.key] = rate
      try save(data: allRates, forKey: .cachedRates)
    }
  }

  func fetchCachedRate(for source: Currency) async throws -> ExchangeRate? {
    guard let rate = try await fetchCachedRates()[source.key],
          isRateValid(rate) else {
      return nil
    }
    return rate
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
    try save(data: Array(conversions.prefix(100)), forKey: .conversionsHistory)
  }

  func fetchLastConversionPair() async -> (Currency, Currency)? {
    guard let data = storage.data(forKey: .lastConversionPair),
          let pair = try? decoder.decode([Currency].self, from: data),
          pair.count == 2 else {
      return nil
    }

    return (pair[0], pair[1])
  }

  func saveConversionPair(source: Currency, target: Currency) async throws {
    try save(data: [source, target], forKey: .lastConversionPair)
  }

  private func isRateValid(_ rate: ExchangeRate) -> Bool {
    Date().timeIntervalSince(rate.timestamp) < cacheMaxAge
  }

  private func save<T: Encodable>(data: T, forKey key: String) throws {
    do {
      let encoded = try encoder.encode(data)
      storage.set(encoded, forKey: key)
    } catch {
      throw PersistenceClient.PersistenceError.storageFailure
    }
  }
}

private extension String {
  static let cachedRates = "cachedExchangeRates"
  static let conversionsHistory = "conversionsHistory"
  static let lastConversionPair = "lastConversionPair"
}
