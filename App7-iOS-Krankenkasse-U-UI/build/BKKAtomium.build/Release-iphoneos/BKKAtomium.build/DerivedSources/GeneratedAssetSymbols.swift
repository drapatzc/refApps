import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "ad-dental" asset catalog image resource.
    static let adDental = DeveloperToolsSupport.ImageResource(name: "ad-dental", bundle: resourceBundle)

    /// The "ad-health-tips" asset catalog image resource.
    static let adHealthTips = DeveloperToolsSupport.ImageResource(name: "ad-health-tips", bundle: resourceBundle)

    /// The "ad-mental-health" asset catalog image resource.
    static let adMentalHealth = DeveloperToolsSupport.ImageResource(name: "ad-mental-health", bundle: resourceBundle)

    /// The "ad-wellness" asset catalog image resource.
    static let adWellness = DeveloperToolsSupport.ImageResource(name: "ad-wellness", bundle: resourceBundle)

    /// The "hero-login" asset catalog image resource.
    static let heroLogin = DeveloperToolsSupport.ImageResource(name: "hero-login", bundle: resourceBundle)

    /// The "hero-mountain" asset catalog image resource.
    static let heroMountain = DeveloperToolsSupport.ImageResource(name: "hero-mountain", bundle: resourceBundle)

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    /// The "ad-dental" asset catalog image.
    static var adDental: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .adDental)
#else
        .init()
#endif
    }

    /// The "ad-health-tips" asset catalog image.
    static var adHealthTips: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .adHealthTips)
#else
        .init()
#endif
    }

    /// The "ad-mental-health" asset catalog image.
    static var adMentalHealth: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .adMentalHealth)
#else
        .init()
#endif
    }

    /// The "ad-wellness" asset catalog image.
    static var adWellness: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .adWellness)
#else
        .init()
#endif
    }

    /// The "hero-login" asset catalog image.
    static var heroLogin: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .heroLogin)
#else
        .init()
#endif
    }

    /// The "hero-mountain" asset catalog image.
    static var heroMountain: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .heroMountain)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// The "ad-dental" asset catalog image.
    static var adDental: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .adDental)
#else
        .init()
#endif
    }

    /// The "ad-health-tips" asset catalog image.
    static var adHealthTips: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .adHealthTips)
#else
        .init()
#endif
    }

    /// The "ad-mental-health" asset catalog image.
    static var adMentalHealth: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .adMentalHealth)
#else
        .init()
#endif
    }

    /// The "ad-wellness" asset catalog image.
    static var adWellness: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .adWellness)
#else
        .init()
#endif
    }

    /// The "hero-login" asset catalog image.
    static var heroLogin: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .heroLogin)
#else
        .init()
#endif
    }

    /// The "hero-mountain" asset catalog image.
    static var heroMountain: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .heroMountain)
#else
        .init()
#endif
    }

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ColorResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

