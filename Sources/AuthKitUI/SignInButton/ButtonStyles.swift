//
//  ButtonStyles.swift
//
//
//  Created by Thanh Duy Truong on 12/12/2022.
//

import SwiftUI
#if os(iOS)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif
struct GoogleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.black)
            .background(Color.white)
    }
}

struct AppleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(foregroundColor)
            .background(bgColor)
    }

    private var foregroundColor: Color {
        #if os(iOS)
            let color = UIColor { trait in
                switch trait.userInterfaceStyle {
                case .dark:
                    return UIColor.black

                case .light:
                    return UIColor.white
                case .unspecified:
                    return UIColor.white
                @unknown default:
                    return UIColor.white
                }
            }
            return Color(color)
        #else
            let color = NSColor(name: nil) { appearance in
                if appearance.isDarkMode {
                    return NSColor.black
                } else {
                    return NSColor.white
                }
            }
            return Color(color)
        #endif
    }

    private var bgColor: Color {
        #if os(iOS)
            let color = UIColor { trait in
                switch trait.userInterfaceStyle {
                case .dark:
                    return UIColor.white
                case .light:
                    return UIColor.black
                case .unspecified:
                    return UIColor.black
                @unknown default:
                    return UIColor.black
                }
            }
            return Color(color)
        #else
            let color = NSColor(name: nil) { appearance in
                if appearance.isDarkMode {
                    return NSColor.white
                } else {
                    return NSColor.black
                }
            }
            return Color(color)
        #endif
    }
}

#if os(macOS)
    private extension NSAppearance {
        var isDarkMode: Bool {
            if self.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua {
                return true
            } else {
                return false
            }
        }
    }
#endif
