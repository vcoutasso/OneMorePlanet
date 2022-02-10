// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
    import AppKit
#elseif os(iOS)
    import UIKit
#elseif os(tvOS) || os(watchOS)
    import UIKit
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetColorTypeAlias = ColorAsset.Color
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Assets {
    internal static let accentColor = ColorAsset(name: "AccentColor")
    internal enum Colors {
        internal static let spaceBackground = ColorAsset(name: "Colors/SpaceBackground")
    }

    internal enum Images {
        internal static let stars = ImageAsset(name: "Images/Stars")
        internal static let alien = ImageAsset(name: "Images/alien")
        internal static let asteroidBelt = ImageAsset(name: "Images/asteroidBelt")
        internal static let asteroids1 = ImageAsset(name: "Images/asteroids1")
        internal static let asteroids2 = ImageAsset(name: "Images/asteroids2")
        internal static let asteroids3 = ImageAsset(name: "Images/asteroids3")
        internal static let asteroids4 = ImageAsset(name: "Images/asteroids4")
        internal static let planet1 = ImageAsset(name: "Images/planet1")
        internal static let planet10 = ImageAsset(name: "Images/planet10")
        internal static let planet11 = ImageAsset(name: "Images/planet11")
        internal static let planet12 = ImageAsset(name: "Images/planet12")
        internal static let planet13 = ImageAsset(name: "Images/planet13")
        internal static let planet14 = ImageAsset(name: "Images/planet14")
        internal static let planet15 = ImageAsset(name: "Images/planet15")
        internal static let planet16 = ImageAsset(name: "Images/planet16")
        internal static let planet17 = ImageAsset(name: "Images/planet17")
        internal static let planet18 = ImageAsset(name: "Images/planet18")
        internal static let planet19 = ImageAsset(name: "Images/planet19")
        internal static let planet2 = ImageAsset(name: "Images/planet2")
        internal static let planet20 = ImageAsset(name: "Images/planet20")
        internal static let planet21 = ImageAsset(name: "Images/planet21")
        internal static let planet22 = ImageAsset(name: "Images/planet22")
        internal static let planet23 = ImageAsset(name: "Images/planet23")
        internal static let planet24 = ImageAsset(name: "Images/planet24")
        internal static let planet25 = ImageAsset(name: "Images/planet25")
        internal static let planet26 = ImageAsset(name: "Images/planet26")
        internal static let planet27 = ImageAsset(name: "Images/planet27")
        internal static let planet3 = ImageAsset(name: "Images/planet3")
        internal static let planet4 = ImageAsset(name: "Images/planet4")
        internal static let planet5 = ImageAsset(name: "Images/planet5")
        internal static let planet6 = ImageAsset(name: "Images/planet6")
        internal static let planet7 = ImageAsset(name: "Images/planet7")
        internal static let planet8 = ImageAsset(name: "Images/planet8")
        internal static let planet9 = ImageAsset(name: "Images/planet9")
    }
}

// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal final class ColorAsset {
    internal fileprivate(set) var name: String

    #if os(macOS)
        internal typealias Color = NSColor
    #elseif os(iOS) || os(tvOS) || os(watchOS)
        internal typealias Color = UIColor
    #endif

    @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
    internal private(set) lazy var color: Color = {
        guard let color = Color(asset: self) else {
            fatalError("Unable to load color asset named \(name).")
        }
        return color
    }()

    #if os(iOS) || os(tvOS)
        @available(iOS 11.0, tvOS 11.0, *)
        internal func color(compatibleWith traitCollection: UITraitCollection) -> Color {
            let bundle = BundleToken.bundle
            guard let color = Color(named: name, in: bundle, compatibleWith: traitCollection) else {
                fatalError("Unable to load color asset named \(name).")
            }
            return color
        }
    #endif

    fileprivate init(name: String) {
        self.name = name
    }
}

internal extension ColorAsset.Color {
    @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
    convenience init?(asset: ColorAsset) {
        let bundle = BundleToken.bundle
        #if os(iOS) || os(tvOS)
            self.init(named: asset.name, in: bundle, compatibleWith: nil)
        #elseif os(macOS)
            self.init(named: NSColor.Name(asset.name), bundle: bundle)
        #elseif os(watchOS)
            self.init(named: asset.name)
        #endif
    }
}

internal struct ImageAsset {
    internal fileprivate(set) var name: String

    #if os(macOS)
        internal typealias Image = NSImage
    #elseif os(iOS) || os(tvOS) || os(watchOS)
        internal typealias Image = UIImage
    #endif

    @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
    internal var image: Image {
        let bundle = BundleToken.bundle
        #if os(iOS) || os(tvOS)
            let image = Image(named: name, in: bundle, compatibleWith: nil)
        #elseif os(macOS)
            let name = NSImage.Name(self.name)
            let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
        #elseif os(watchOS)
            let image = Image(named: name)
        #endif
        guard let result = image else {
            fatalError("Unable to load image asset named \(name).")
        }
        return result
    }

    #if os(iOS) || os(tvOS)
        @available(iOS 8.0, tvOS 9.0, *)
        internal func image(compatibleWith traitCollection: UITraitCollection) -> Image {
            let bundle = BundleToken.bundle
            guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
                fatalError("Unable to load image asset named \(name).")
            }
            return result
        }
    #endif
}

internal extension ImageAsset.Image {
    @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
    @available(macOS, deprecated,
               message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
    convenience init?(asset: ImageAsset) {
        #if os(iOS) || os(tvOS)
            let bundle = BundleToken.bundle
            self.init(named: asset.name, in: bundle, compatibleWith: nil)
        #elseif os(macOS)
            self.init(named: NSImage.Name(asset.name))
        #elseif os(watchOS)
            self.init(named: asset.name)
        #endif
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
