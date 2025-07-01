// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "currency-converter",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(name: .Feature.app, targets: [.Feature.app]),
  ],
  dependencies: [
    .package(
      url: "https://github.com/apple/swift-algorithms",
      from: "1.2.1"
    ),
    .package(
      url: "https://github.com/apple/swift-collections",
      from: "1.1.4"
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture",
      from: "1.18.0"
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-dependencies",
      from: "1.8.1"
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-tagged",
      from: "0.10.0"
    ),
  ],
  targets: [
    .model,
    .resources,
    .sharedUI,
    .Client.persistence,
    .Client.exchange,
    .Feature.currencyConversion,
    .Feature.currencyHistory,
    .Feature.app
  ]
)

extension Target {
  static let sharedUI = target(
    name: .sharedUI,
    dependencies: [
      .resources,
    ]
  )

  static let model = target(
    name: .model,
    dependencies: [
      .External.tagged,
      .resources
    ]
  )

  static let resources = target(
    name: .resources,
    exclude: ["swiftgen.yml"],
    resources: [
      .process("Resources")
    ]
  )

  enum Client {
    static let persistence = target(
      name: .Client.persistence,
      dependencies: [
        .model,
        .External.tagged,
        .External.composableArchitecture,
      ]
    )

    static let exchange = target(
      name: .Client.exchange,
      dependencies: [
        .model,
        .Client.persistence,
        .External.tagged,
        .External.composableArchitecture,
      ]
    )
  }

  enum Feature {
    static let app = target(
      name: .Feature.app,
      dependencies: [
        .resources,
        .Client.persistence,
        .Client.exchange,
        .Feature.currencyConversion,
        .Feature.conversionHistory,
        .External.composableArchitecture,
      ]
    )

    static let currencyConversion = target(
      name: .Feature.currencyConversion,
      dependencies: [
        .Client.persistence,
        .Client.exchange,
        .sharedUI,
        .resources,
        .External.composableArchitecture
      ]
    )

    static let currencyHistory = target(
      name: .Feature.conversionHistory,
      dependencies: [
        .Client.persistence,
        .sharedUI,
        .resources,
        .External.composableArchitecture
      ]
    )
  }
}

extension Target.Dependency {
  static let model = byName(name: .model)
  static let resources = byName(name: .resources)
  static let sharedUI = byName(name: .sharedUI)

  enum Client {
    static let persistence = byName(name: .Client.persistence)
    static let exchange = byName(name: .Client.exchange)
  }

  enum Feature {
    static let app = byName(name: .Feature.app)
    static let currencyConversion = byName(name: .Feature.currencyConversion)
    static let conversionHistory = byName(name: .Feature.conversionHistory)
  }

  enum External {
    static let composableArchitecture = product(
      name: "ComposableArchitecture",
      package: "swift-composable-architecture"
    )

    enum Collections {
      static let orderedCollections = product(
        name: "OrderedCollections",
        package: "swift-collections"
      )
    }

    static let tagged = product(
      name: "Tagged",
      package: "swift-tagged"
    )
  }
}

extension String {
  static let model = "Model"
  static let resources = "Resources"
  static let sharedUI = "SharedUI"

  enum Client {
    static let persistence = "PersistenceClient"
    static let exchange = "ExchangeClient"
  }

  enum Feature {
    static let app = "AppFeature"
    static let currencyConversion = "CurrencyConversionFeature"
    static let conversionHistory = "ConversionHistoryFeature"
  }
}
