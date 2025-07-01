// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum L10n {
  public enum Button {
    /// Cancel
    public static let cancel = L10n.tr("Localizable", "Button.cancel", fallback: "Cancel")
    /// Copy
    public static let copy = L10n.tr("Localizable", "Button.copy", fallback: "Copy")
    /// Copy All
    public static let copyAll = L10n.tr("Localizable", "Button.copyAll", fallback: "Copy All")
    /// Delete
    public static let delete = L10n.tr("Localizable", "Button.delete", fallback: "Delete")
    /// Done
    public static let done = L10n.tr("Localizable", "Button.done", fallback: "Done")
    /// OK
    public static let ok = L10n.tr("Localizable", "Button.ok", fallback: "OK")
    /// Go to Settings
    public static let openSettings = L10n.tr("Localizable", "Button.openSettings", fallback: "Go to Settings")
  }
  public enum Shared {
    /// Clear
    public static let clear = L10n.tr("Localizable", "Shared.clear", fallback: "Clear")
  }
  public enum Conversion {
    public enum FromPicker {
      /// From
      public static let title = L10n.tr("Localizable", "conversion.fromPicker.title", fallback: "From")
    }
    public enum SourceAmount {
      /// Amount
      public static let title = L10n.tr("Localizable", "conversion.sourceAmount.title", fallback: "Amount")
    }
    public enum ToPicker {
      /// To
      public static let title = L10n.tr("Localizable", "conversion.toPicker.title", fallback: "To")
    }
  }
  public enum ConversionHistory {
    /// No history yet
    public static let emptyHistory = L10n.tr("Localizable", "conversionHistory.emptyHistory", fallback: "No history yet")
    /// No results for '%@'
    public static func noSearchResults(_ p1: Any) -> String {
      return L10n.tr("Localizable", "conversionHistory.noSearchResults", String(describing: p1), fallback: "No results for '%@'")
    }
    /// Rate: %@
    public static func rateLabel(_ p1: Any) -> String {
      return L10n.tr("Localizable", "conversionHistory.rateLabel", String(describing: p1), fallback: "Rate: %@")
    }
    /// Search by currency
    public static let searchPlaceholder = L10n.tr("Localizable", "conversionHistory.searchPlaceholder", fallback: "Search by currency")
    public enum NavBar {
      /// Conversion History
      public static let title = L10n.tr("Localizable", "conversionHistory.navBar.title", fallback: "Conversion History")
    }
  }
  public enum TabBar {
    public enum Convert {
      /// Convert
      public static let title = L10n.tr("Localizable", "tabBar.convert.title", fallback: "Convert")
    }
    public enum History {
      /// History
      public static let title = L10n.tr("Localizable", "tabBar.history.title", fallback: "History")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = Bundle.module.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}
// swiftlint:enable all
