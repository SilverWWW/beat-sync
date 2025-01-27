//
//  BSImage.swift
//  beat-sync-app
//
//  Created by Will Silver on 1/19/25.
//

import Foundation
import SwiftUI


extension Image {
    static func BS(_ image: String,
                   color: Color? = nil) -> some View {
        Image(image)
            .renderingMode(color == nil ? .original : .template)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(color ?? .primary)
    }
    
    static func BS(uiImage: UIImage,
                   color: Color? = nil) -> some View {
        Image(uiImage: uiImage)
            .renderingMode(color == nil ? .original : .template)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(color ?? .primary)
    }
    
    static func BS(systemName: String,
                   color: Color? = nil) -> some View {
        Image(systemName: systemName)
            .renderingMode(color == nil ? .original : .template)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(color ?? .primary)
    }
}
