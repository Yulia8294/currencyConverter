import Model
import Foundation
import PersistenceClient

public extension ExchangeClient {
  static func live(
    persistenceClient: PersistenceClient,
    session: URLSession = .shared,
    cacheMaxAge: TimeInterval = 7200
  ) -> ExchangeClient {
    let impl = ExchangeClientImpl(
      persistenceClient: persistenceClient,
      session: session,
      cacheMaxAge: cacheMaxAge
    )

    return Self(
      initialize: {
        try impl.initialize()
      },
      convert: {
        try await impl.convert($0)
      }
    )
  }
}

private final class ExchangeClientImpl {
  let persistenceClient: PersistenceClient
  let session: URLSession
  let cacheMaxAge: TimeInterval

  let decoder = JSONDecoder()
  var apiKey: String = ""

  init(persistenceClient: PersistenceClient, session: URLSession, cacheMaxAge: TimeInterval) {
    self.persistenceClient = persistenceClient
    self.session = session
    self.cacheMaxAge = cacheMaxAge
  }

  func initialize() throws {
    let bundle = Bundle.main
    guard let apiKey = bundle.exchangeApiKey else {
      throw ExchangeClient.ExchangeError.apiKeyMissing
    }
    self.apiKey = apiKey
  }

  private struct APIResponse: Decodable {
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
    guard !apiKey.isEmpty else {
      throw ExchangeClient.ExchangeError.apiKeyMissing
    }

    let url = try buildURL(for: source)
    let request = buildRequest(for: url)

    do {
      let (data, _) = try await session.data(from: url)
      let result = try decoder.decode(APIResponse.self, from: data)

      return ExchangeRate(
        source: source,
        rates: result.data,
        timestamp: Date()
      )
    } catch let error as DecodingError {
      throw ExchangeClient.ExchangeError.decodingError(underlying: error.localizedDescription)
    } catch let error as ExchangeClient.ExchangeError {
      throw error
    } catch {
      throw ExchangeClient.ExchangeError.networkError(description: error.localizedDescription)
    }
  }

  private func buildURL(for source: Currency) throws -> URL {
    guard let url = URL(string: .apiRoot) else {
      throw ExchangeClient.ExchangeError.invalidRequest(reason: "Invalid API URL")
    }

    return url.appending(
      queryItems: [
        URLQueryItem(name: .apiKeyParam, value: apiKey),
        URLQueryItem(name: .baseCurrencyParam, value: source.key)
      ]
    )
  }

  private func buildRequest(for url: URL) -> URLRequest {
    var request = URLRequest(url: url)
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("public, max-age=\(Int(cacheMaxAge))", forHTTPHeaderField: "Cache-Control")
    request.timeoutInterval = 30
    return request
  }
}

private extension String {
  static let baseCurrencyParam = "base_currency"
  static let apiKeyParam = "apikey"
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
