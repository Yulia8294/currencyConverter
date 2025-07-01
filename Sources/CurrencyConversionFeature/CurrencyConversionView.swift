import ComposableArchitecture
import SwiftUI
import Model
import Resources

public struct CurrencyConverterView: View {
  @Bindable var store: StoreOf<CurrencyConversion>

  public init(store: StoreOf<CurrencyConversion>) {
    self.store = store
  }

  public var body: some View {
    VStack {
      Form {
        Picker(
          L10n.Conversion.FromPicker.title,
          selection: $store.sourceCurrency
        ) {
          ForEach(Currency.allCases, id: \.self) {
            Text($0.key)
          }
        }

        Picker(
          L10n.Conversion.ToPicker.title,
          selection: $store.targetCurrency
        ) {
          ForEach(Currency.allCases, id: \.self) {
            Text($0.key)
          }
        }

        HStack {
          TextField(
            L10n.Conversion.SourceAmount.title,
            value: $store.sourceValue,
            formatter: NumberFormatter())

          Spacer()

          Text(store.sourceCurrency.key)
        }

        HStack {
          if let result = store.resultValue {
            Text("\(result)")
          }

          Spacer()

          Text(store.targetCurrency.key)
        }

        if let error = store.errorMessage {
          Text(error).foregroundColor(.red)
        }
      }

      if store.isLoading {
        ProgressView()
      }
    }
    .onAppear {
      store.send(.onAppear)
    }
  }
}
