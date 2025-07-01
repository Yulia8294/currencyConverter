import Dependencies
import PersistenceClient
import ExchangeClient

extension PersistenceClient: @retroactive DependencyKey {
  public static let liveValue = Self.live
}

extension ExchangeClient: @retroactive DependencyKey {
  public static let liveValue = Self.live(
    persistenceClient: PersistenceClient.liveValue
  )
}
