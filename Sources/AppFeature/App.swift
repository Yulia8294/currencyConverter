import ComposableArchitecture
import Resources
import SwiftUI
import CurrencyConversionFeature
import ConversionHistoryFeature

@Reducer
public struct AppReducer {
  public enum Action {
    case appDelegate(AppDelegateReducer.Action)
    case conversions(CurrencyConversion.Action)
    case history(ConversionHistory.Action)

    case tabSelected(Tab)
    case onChangeScenePhase(ScenePhase)
  }

  public enum AlertAction: Equatable {}

  @ObservableState
  public struct State: Equatable {
    public var tabSelected: Tab = .conversion

    public var appDelegate = AppDelegateReducer.State()
    public var conversions = CurrencyConversion.State()
    public var history = ConversionHistory.State()

    public init() {}
  }

  public enum Tab: CaseIterable, Equatable, Hashable {
    case conversion
    case history
  }

  public init() {}

  @Dependency(\.exchangeClient) var exchangeClient

  public var body: some ReducerOf<Self> {
    CombineReducers {
      Scope(state: \.appDelegate, action: \.appDelegate) {
        AppDelegateReducer()
      }

      Scope(state: \.conversions, action: \.conversions) {
        CurrencyConversion()
      }

      Scope(state: \.history, action: \.history) {
        ConversionHistory()
      }

      coreBody
    }
  }

  private var coreBody: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .appDelegate(.didFinishLaunching):
        exchangeClient.initialize()
        return .none
      case .appDelegate:
        return .none
      case .onChangeScenePhase:
        return .none
      case .conversions:
        return .none
      case .history:
        return .none
      case .tabSelected(let tab):
        state.tabSelected = tab
        return .none
      }
    }
  }
}
