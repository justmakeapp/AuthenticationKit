//
//  View+Extension.swift
//
//
//  Created by Long Vu on 23/07/2023.
//

import FoundationX
import SwiftUI

extension View {
    func textFieldStyling() -> some View {
        font(.body)
        #if os(macOS)
            .textFieldStyle(.roundedBorder)
        #endif
        #if os(iOS)
        .padding(.horizontal, 12)
        .frame(height: 44.scaledToMac())
        .frame(maxWidth: .infinity)
        .overlay {
            RoundedRectangle(cornerRadius: 10.onMac(7))
                .stroke(Color(.separator), lineWidth: 1)
        }
        #endif
    }
}
