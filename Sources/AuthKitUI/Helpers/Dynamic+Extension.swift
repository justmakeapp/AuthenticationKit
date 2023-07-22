//
//  Dynamic+Extension.swift
//
//
//  Created by Long Vu on 22/07/2023.
//

#if targetEnvironment(macCatalyst)
    import Dynamic
    import UIKit

    final class NSApplication {
        private static var dynamicSharedApplication = Dynamic.NSApplication.sharedApplication

        private init() {}

        static func loadIconImageData() -> Data? {
            let object = dynamicSharedApplication.applicationIconImage.TIFFRepresentation.asObject
            return object as? Data
        }
    }
#endif
