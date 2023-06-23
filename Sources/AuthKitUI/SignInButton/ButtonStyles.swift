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
        switch colorScheme {
        case .dark:
            return Color.black
        case .light:
            return Color.white
        @unknown default:
            return Color.black
        }
    }

    private var bgColor: Color {
        switch colorScheme {
        case .dark:
            return Color.white
        case .light:
            return Color.black
        @unknown default:
            return Color.white
        }
    }
}
