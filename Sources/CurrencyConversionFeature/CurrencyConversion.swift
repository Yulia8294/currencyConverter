// swiftlint:disable closure_parameter_position
import ComposableArchitecture
import Model
import Foundation
import PersistenceClient
import ExchangeClient

@Reducer
public struct CurrencyConversion {
  public enum Action: BindableAction {
    case onAppear
    case binding(BindingAction<State>)

    case conversionResponse(Result<Conversion, Error>)
    case lastPairResponse((Currency, Currency)?)
  }

  @ObservableState
  public struct State: Equatable {

    var sourceCurrency: Currency = .usd
    var targetCurrency: Currency = .rub
    var sourceValue: Double = 1
    var resultValue: Double?

    var isLoading = false

    var errorMessage: String?

    public init() {}
  }

  private enum CancelID {
    case debounceRequest
  }

  public init() {}

  @Dependency(\.exchangeClient) var exchangeClient
  @Dependency(\.persistenceClient) var persistenceClient
  @Dependency(\.mainQueue) var mainQueue

  public var body: some ReducerOf<Self> {
    BindingReducer()
    coreReducer
  }

  @ReducerBuilder<State, Action>
  private var coreReducer: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        return fetchLastPair(state: &state)
      case .lastPairResponse(let pair):
        if let pair {
          state.sourceCurrency = pair.0
          state.targetCurrency = pair.1
        }

        return .none
      case .binding(\.sourceValue):
        return convert(state: &state)
      case .binding(\.sourceCurrency), .binding(\.targetCurrency):
        return .merge(
          convert(state: &state),
          .run(priority: .low) {
            [source = state.sourceCurrency, target = state.targetCurrency] _ in
            try await persistenceClient.saveConversionPair(source, target)
          }
        )
      case .binding:
        return .none
      case let .conversionResponse(response):
        state.isLoading = false
        state.errorMessage = nil

        switch (response) {
        case .success(let conversion):
          state.resultValue = conversion.targetValue

          return .run(priority: .low) { _ in
            try await persistenceClient.saveConversion(conversion)
          }
        case .failure(let error):
          state.errorMessage = error.localizedDescription
        }
        return .none
      }
    }
  }

  private func convert(
    state: inout State
  ) -> Effect<Action> {
    state.isLoading = true

    return .run { [
      amount = state.sourceValue,
      source = state.sourceCurrency,
      target = state.targetCurrency
    ] send in

      let result = await Result {
        try await exchangeClient.convert(
          .init(
            source: source,
            target: target,
            amount: amount
          )
        )
      }
      await send(.conversionResponse(result))
    }
    .debounce(
      id: CancelID.debounceRequest,
      for: 0.2,
      scheduler: mainQueue
    )
  }

  private func fetchLastPair(
    state: inout State
  ) -> Effect<Action> {
    return .run { send in
      let result = await persistenceClient.fetchLastConversionPair()
      await send(.lastPairResponse(result))
    }
  }
}
// swiftlint:enable closure_parameter_position
