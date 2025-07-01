import Dependencies
import XCTestDynamicOverlay

extension PersistenceClient: TestDependencyKey {
  public static var previewValue = Self.noop

  public static let testValue = Self()
}

extension PersistenceClient {
  public static let noop = Self(
    fetchCachedRates: { [:] },
    fetchCachedRate: { _ in nil },
    cacheRates: { _ in },
    fetchConversionsHistory: { [] },
    saveConversion: { _ in },
    fetchLastConversionPair: { nil },
    saveConversionPair: { _, _ in }
  )
}
