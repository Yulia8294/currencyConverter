import ComposableArchitecture
import PersistenceClient
import Model

@Reducer
public struct ConversionHistory {
  public enum Action {
    case onAppear
    case loadHistoryResponse([Conversion])
    case searchQueryChanged(String)
  }

  @ObservableState
  public struct State: Equatable {
    var history: [Conversion] = []
    var searchQuery = ""
    var errorMessage: String?

    var filteredConversions: [Conversion] {
      if searchQuery.isEmpty {
        return history
      }
      return history.filter {
        $0.source.rawValue.localizedCaseInsensitiveContains(searchQuery) ||
        $0.target.rawValue.localizedCaseInsensitiveContains(searchQuery)
      }
    }

    public init() {}
  }

  @Dependency(\.persistenceClient) var persistenceClient

  public init() {}

  public var body: some ReducerOf<Self> {
    coreReducer
  }

  @ReducerBuilder<State, Action>
  private var coreReducer: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .run { send in
          let history = try await persistenceClient.fetchConversionsHistory()
          await send(.loadHistoryResponse(history))
        }

      case .loadHistoryResponse(let conversions):
        state.history = conversions
        return .none
      case .searchQueryChanged(let query):
        state.searchQuery = query
        return .none
      }
    }
  }
}
