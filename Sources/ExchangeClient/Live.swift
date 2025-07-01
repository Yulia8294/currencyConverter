import Model
import Foundation
import PersistenceClient

public extension ExchangeClient {
  static func live(
    persistenceClient: PersistenceClient
  ) -> ExchangeClient {
    let impl = ExchangeClientImpl(
      persistenceClient: persistenceClient
    )

    return Self(
      initialize: {
        impl.initialize()
      },
      convert: {
        try await impl.convert($0)
      }
    )
  }
}

private final class ExchangeClientImpl {
  let persistenceClient: PersistenceClient

  let decoder = JSONDecoder()
  let session = URLSession.shared
  let cacheMaxAge: TimeInterval = 7200
  var apiKey: String = ""

  init(persistenceClient: PersistenceClient) {
    self.persistenceClient = persistenceClient
  }

  func initialize() {
    let bundle = Bundle.main
    guard let apiKey = bundle.exchangeApiKey else {
      assertionFailure("Cannot find valid Exchange settings")
      self.apiKey = ""
      return
    }
    self.apiKey = apiKey
  }

  private struct Response: Decodable {
    let data: [String: Double]
  }

  func convert(_ request: ConvertRequest) async throws -> Conversion {
    let calcResult = { (rate: ExchangeRate) in
      guard let targetRate = rate.rates[request.target.key] else {
        throw ExchangeClient.ExchangeError.exchangeRateNotFound
      }

      return Conversion(
        id: UUID(),
        date: Date(),
        source: request.source,
        target: request.target,
        sourceValue: request.amount,
        targetValue: targetRate * request.amount,
        exchangeRate: targetRate
      )
    }

    if let cachedRate = try await persistenceClient.fetchCachedRate(request.source) {
      return try calcResult(cachedRate)
    }

    let rate = try await fetchExchangeRate(
      source: request.source,
      target: request.target
    )

    try await persistenceClient.cacheRates(rate)

    return try calcResult(rate)
  }

  private func fetchExchangeRate(
    source: Currency,
    target: Currency
  ) async throws -> ExchangeRate {
    let url = URL(string: .apiRoot)!
      .appending(
        queryItems: [
          .init(name: .apiKeyKey, value: apiKey),
          .init(name: .baseCurrencyKey, value: source.key)
        ]
      )

    var request = URLRequest(url: url)
    request.allHTTPHeaderFields = [
      "cache-control": "public, max-age:\(cacheMaxAge)"
    ]

    let (data, res) = try await session.data(from: url)
    print(res)
    let result = try decoder.decode(Response.self, from: data)

    return ExchangeRate(
      source: source,
      rates: result.data,
      timestamp: Date()
    )
  }
}

private extension String {
  static let baseCurrencyKey = "base_currency"
  static let apiKeyKey = "apikey"
  static let apiRoot = "https://api.freecurrencyapi.com/v1/latest"
}

extension Bundle {
  public subscript(_ key: String) -> Any? {
    infoDictionary?[key]
  }

  public var exchangeApiKey: String? {
    self["XExchangeRateApiKey"] as? String
  }
}
