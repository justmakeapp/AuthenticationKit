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
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(Color(.systemBackground))
            .background(
                Color(UIColor { traitCollection in
                    switch traitCollection.userInterfaceStyle {
                    case .dark:
                        return .white
                    default:
                        return .black
                    }
                })
            )
    }
}
