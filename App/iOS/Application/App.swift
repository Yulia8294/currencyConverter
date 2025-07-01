import ComposableArchitecture
import Resources
import SwiftUI
import UIKit
import AppFeature

final class AppDelegate: NSObject {
  let store = Store(initialState: AppReducer.State()) {
    AppReducer()
  }
}

// MARK: - UIApplicationDelegate

extension AppDelegate: UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    store.send(.appDelegate(.willFinishLaunching(launchOptions)))
    return true
  }

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    store.send(.appDelegate(.didFinishLaunching(launchOptions)))
    return true
  }
}

@main
struct App: SwiftUI.App {
  @UIApplicationDelegateAdaptor(AppDelegate.self)
  private var appDelegate

  // MARK: - App

  var body: some Scene {
    WindowGroup {
      AppView(store: appDelegate.store)
    }
  }
}
