import ComposableArchitecture
import SwiftUI
import Resources
import CurrencyConversionFeature
import ConversionHistoryFeature

public struct AppView: View {
  @Bindable var store: StoreOf<AppReducer>

  public init(store: StoreOf<AppReducer>) {
    self.store = store
  }

  @Environment(\.scenePhase) var scenePhase

  public var body: some View {
    TabView(selection: $store.tabSelected.sending(\.tabSelected)) {
      CurrencyConverterView(
        store: store.scope(
          state: \.conversions,
          action: \.conversions
        )
      )
      .tabItem {
        TabItem(
          L10n.TabBar.Convert.title,
          systemIconName: "dollarsign.arrow.circlepath"
        )
      }
      .tag(AppReducer.Tab.conversion)

      HistoryFeatureView(
        store: store.scope(
          state: \.history,
          action: \.history
        )
      )
      .tabItem {
        TabItem(
          L10n.TabBar.History.title,
          systemIconName: "clock"
        )
      }
      .tag(AppReducer.Tab.history)
    }
    .onChange(of: scenePhase) { _, newPhase in
      store.send(.onChangeScenePhase(newPhase))
    }
    .foregroundStyle(
      ColorCatalog.primary.swiftUIColor,
      ColorCatalog.secondary.swiftUIColor,
      ColorCatalog.tertiary.swiftUIColor
    )
    .backgroundStyle(ColorCatalog.background.swiftUIColor)
    .tint(ColorCatalog.tint.swiftUIColor)
    .preferredColorScheme(.dark)
  }
}

private struct TabItem: View {
  @Environment(\.isEnabled) private var isEnabled

  private let title: String
  private let systemIconName: String

  init(
    _ title: String,
    systemIconName: String
  ) {
    self.title = title
    self.systemIconName = systemIconName
  }

  var body: some View {
    VStack(spacing: 4) {
      Image(systemName: systemIconName)
        .symbolVariant(.fill)
        .font(.system(size: 18, weight: .medium))
        .frame(width: 24, height: 24)

      Text(title)
        .font(.system(size: 10, weight: .medium))
    }
    .foregroundColor(isEnabled ? .primary : .secondary)
  }
}
