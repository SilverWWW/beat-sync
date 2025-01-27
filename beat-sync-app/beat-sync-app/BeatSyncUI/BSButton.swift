//
//  BSButton.swift
//  beat-sync-app
//
//  Created by Will Silver on 1/19/25.
//

import Foundation
import SwiftUI

struct GradientRippleButton: View {
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var rippleScale: CGFloat = 0
    @State private var rippleOpacity: Double = 0
    private let rippleTime: Double = 0.5

    var body: some View {
        ZStack {
            // Gradient Ripple Effect
            Circle()
                .fill(
                    BSColor.beatsyncDark.opacity(0.5)
                )
                .frame(width: 200, height: 200)
                .scaleEffect(rippleScale)
                .opacity(rippleOpacity)
                .animation(.easeOut(duration: rippleTime), value: rippleScale)
                .animation(.easeOut(duration: rippleTime), value: rippleOpacity)

            // Button Label
            Button(action: {
                self.action()
                if !isPressed {
                    self.triggerRipple()
                }
            }) {
                Image.BS("beat-sync-circle-logo-green")
                    .frame(width: 200, height: 200)
                    .rotationEffect(Angle(degrees: -10))
                    .overlay (
                        Circle()
                            .stroke(.white, lineWidth: 4)
                    )
                    .scaleEffect(isPressed ? 0.95 : 1.0)
                    .shadow(
                        color: Color.black.opacity(isPressed ? 0.2 : 0.5),
                        radius: isPressed ? 2 : 10,
                        x: 0,
                        y: isPressed ? 1 : 5
                    )
                    .animation(.easeInOut(duration: 0.2), value: isPressed)
            }
        }
    }
    
    private func triggerRipple() {
        rippleScale = 1.0 // Start small
        rippleOpacity = 1.0 // Start visible
        
        DispatchQueue.main.async {
            isPressed = true
            rippleScale = 2.0 // Expand outward
            rippleOpacity = 0.0 // Fade out
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + rippleTime) {
            isPressed = false
            rippleScale = 1.0
            rippleOpacity = 0.0
        }
    }
}

