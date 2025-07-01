import SwiftUI
import Model
import ComposableArchitecture
import Resources

public struct HistoryFeatureView: View {
  @Bindable var store: StoreOf<ConversionHistory>

  public init(store: StoreOf<ConversionHistory>) {
    self.store = store
  }

  public var body: some View {
    NavigationStack {
      List {
        searchSection()

        if store.filteredConversions.isEmpty {
          emptyStateView()
        } else {
          historySection()
        }
      }
      .navigationTitle(L10n.ConversionHistory.NavBar.title)
      .onAppear {
        store.send(.onAppear)
      }
    }
  }

  private func searchSection() -> some View {
    Section {
      TextField(
        L10n.ConversionHistory.searchPlaceholder,
        text: $store.searchQuery.sending(\.searchQueryChanged)
      )
      .textFieldStyle(.roundedBorder)
      .autocorrectionDisabled()
      .textInputAutocapitalization(.characters)
      .listRowInsets(EdgeInsets())
      .listRowBackground(Color.clear)
    }
  }

  private func emptyStateView() -> some View {
    Section {
      VStack(alignment: .center, spacing: 8) {
        Image(systemName: "clock.badge.questionmark")
          .font(.system(size: 40))
          .foregroundColor(.gray)

        Text(
          store.searchQuery.isEmpty
          ? L10n.ConversionHistory.emptyHistory
          : L10n.ConversionHistory.noSearchResults(store.searchQuery)
        )
        .font(.headline)
        .foregroundColor(.gray)
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 40)
    }
  }

  private func historySection() -> some View {
    Section {
      ForEach(store.filteredConversions) { conversion in
        ConversionRowView(conversion: conversion)
      }
    }
  }

  private struct ConversionRowView: View {
    let conversion: Conversion

    var body: some View {
      VStack(alignment: .leading, spacing: 4) {
        amountConversionView
        rateAndDateView
      }
    }

    private var amountConversionView: some View {
      HStack {
        amountText(amount: conversion.sourceValue, currency: conversion.source.key)
        Image(systemName: "arrow.right")
          .foregroundColor(.secondary)
        amountText(amount: conversion.targetValue, currency: conversion.target.key)
      }
      .font(.headline)
    }

    private var rateAndDateView: some View {
      HStack(spacing: 16) {
        Text(L10n.ConversionHistory.rateLabel(formattedRate))
        Spacer()
        Text(formattedDate)
      }
      .font(.caption)
      .foregroundColor(.secondary)
    }

    private func amountText(amount: Double, currency: String) -> Text {
      Text("\(amount.formatted(.number.precision(.fractionLength(2)))) \(currency)")
    }

    private var formattedRate: String {
      conversion.exchangeRate.formatted(.number.precision(.fractionLength(4)))
    }

    private var formattedDate: String {
      conversion.date.formatted(
        date: .abbreviated,
        time: .shortened
      )
    }
  }
}
