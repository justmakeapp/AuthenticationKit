//
//  Bundle+Extension.swift
//
//
//  Created by Long Vu on 22/07/2023.
//

import Foundation
#if canImport(UIKit)
    import UIKit
#endif
#if canImport(AppKit)
    import AppKit
#endif
import SwiftUI

extension Bundle {
    var icon: Image? {
        #if canImport(UIKit)
            let uiImage: UIImage? = {
                #if targetEnvironment(macCatalyst)
                    if let iconImageData = NSApplication.loadIconImageData() {
                        return UIImage(data: iconImageData)
                    }
                #else
                    if let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
                       let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
                       let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
                       let lastIcon = iconFiles.last {
                        return UIImage(named: lastIcon)
                    }

                #endif

                return nil
            }()

            if let uiImage {
                return Image(uiImage: uiImage)
            }
        #endif

        #if os(macOS)
            if
                let data = NSApplication.shared.applicationIconImage.tiffRepresentation,
                let nsImage = NSImage(data: data) {
                return Image(nsImage: nsImage)
            }
        #endif

        return nil
    }
}
