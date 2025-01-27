//
//  BSColor.swift
//  beat-sync-app
//
//  Created by Will Silver on 1/19/25.
//

import Foundation
import SwiftUI


class BSColor {
    static let beatsyncDark: Color = Color(hex: 0x1db954)
    static let beatsyncDarkNeon: Color = Color(hex: 0x33ff00)
    static let beatsyncLight: Color = Color(hex: 0xa2ff72)
    static let beatsyncDarkGrey: Color = Color(hex: 0x333333)
    static let beatsyncGrey: Color = Color(hex: 0x444444)
    static let beatsyncLightGrey: Color = Color(hex: 0x888888)
    static let beatsyncGradientLight: Color = Color(hex: 0x1dd054)
    static let beatsyncGradientDark: Color = Color(hex: 0x1D9054)
}

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        let r = Double((hex & 0xFF0000) >> 16) / 255.0
        let g = Double((hex & 0x00FF00) >> 8) / 255.0
        let b = Double(hex & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b, opacity: alpha)
    }
}
