import Foundation
import Dependencies
import Model
import XCTestDynamicOverlay

extension ExchangeClient: TestDependencyKey {
  public static var previewValue = Self.noop

  public static let testValue = Self()
}

extension ExchangeClient {
  public static let noop = Self(
    initialize: {},
    convert: { _ in throw ExchangeClient.ExchangeError.exchangeRateNotFound }
  )
}
