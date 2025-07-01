public typealias ColorCatalog = XCAsset.ColorCatalog
public typealias MediaCatalog = XCAsset.MediaCatalog

extension ImageAsset: Equatable {
  public static func == (lhs: ImageAsset, rhs: ImageAsset) -> Bool {
    lhs.name == rhs.name
  }
}

extension ImageAsset: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(name)
  }
}

extension ImageAsset: @unchecked Sendable {}
