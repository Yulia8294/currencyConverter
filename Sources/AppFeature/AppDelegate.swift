import ComposableArchitecture
import UIKit

public struct AppDelegateReducer: Reducer {
  public enum Action: Equatable, @unchecked Sendable {
    case willFinishLaunching([UIApplication.LaunchOptionsKey: Any]?)
    case didFinishLaunching([UIApplication.LaunchOptionsKey: Any]?)
    case didRegisterForRemoteNotifications(TaskResult<Data>)
    case openURL(URL, options: [UIApplication.OpenURLOptionsKey: Any])

    public static func == (lhs: Self, rhs: Self) -> Bool {
      switch (lhs, rhs) {
      case (.willFinishLaunching, .willFinishLaunching):
        return true
      case (.didFinishLaunching, .didFinishLaunching):
        return true
      case let (.openURL(lhs, _), .openURL(rhs, _)):
        return lhs == rhs
      default:
        return false
      }
    }
  }

  public struct State: Equatable {}

  public init() {}

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .willFinishLaunching:
        return .none
      case .didFinishLaunching:
        return .none
      case .openURL:
        return .none
      case .didRegisterForRemoteNotifications:
        return .none
      }
    }
  }
}
