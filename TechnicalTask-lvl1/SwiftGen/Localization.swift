// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum Localization {
  internal enum AddUser {
    /// City:
    internal static let city = Localization.tr("Localizable", "AddUser.City", fallback: "City:")
    /// User Email:
    internal static let email = Localization.tr("Localizable", "AddUser.Email", fallback: "User Email:")
    /// Email is not valid
    internal static let emailNotValid = Localization.tr("Localizable", "AddUser.EmailNotValid", fallback: "Email is not valid")
    /// Provide all info to save user:
    internal static let provideInfo = Localization.tr("Localizable", "AddUser.ProvideInfo", fallback: "Provide all info to save user:")
    /// Street:
    internal static let street = Localization.tr("Localizable", "AddUser.Street", fallback: "Street:")
    /// Add User
    internal static let title = Localization.tr("Localizable", "AddUser.Title", fallback: "Add User")
    /// Username:
    internal static let username = Localization.tr("Localizable", "AddUser.Username", fallback: "Username:")
  }
  internal enum Button {
    /// Save
    internal static let save = Localization.tr("Localizable", "Button.Save", fallback: "Save")
  }
  internal enum Placeholder {
    /// City
    internal static let city = Localization.tr("Localizable", "Placeholder.City", fallback: "City")
    /// Email
    internal static let email = Localization.tr("Localizable", "Placeholder.Email", fallback: "Email")
    /// Street
    internal static let street = Localization.tr("Localizable", "Placeholder.Street", fallback: "Street")
    /// Username
    internal static let username = Localization.tr("Localizable", "Placeholder.Username", fallback: "Username")
  }
  internal enum UserList {
    /// No Internet Connection. You are in offline mode.
    internal static let noInternet = Localization.tr("Localizable", "UserList.NoInternet", fallback: "No Internet Connection. You are in offline mode.")
    /// User List
    internal static let title = Localization.tr("Localizable", "UserList.Title", fallback: "User List")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension Localization {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
