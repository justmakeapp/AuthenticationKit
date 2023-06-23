//
//  ButtonStyles.swift
//
//
//  Created by Thanh Duy Truong on 12/12/2022.
//

import SwiftUI

struct GoogleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.black)
            .background(Color.white)
    }
}

struct AppleStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme

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
            switch colorScheme {
            case .dark:
                return Color.black
            case .light:
                return Color.white
            @unknown default:
                return Color.black
            }
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
            switch colorScheme {
            case .dark:
                return Color.white
            case .light:
                return Color.black
            @unknown default:
                return Color.white
            }
        #endif
    }
}
