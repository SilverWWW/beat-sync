//
//  BSText.swift
//  beat-sync-app
//
//  Created by Will Silver on 1/19/25.
//

import Foundation
import SwiftUI

extension Text {
    
    static func BS(_ content: String,
                   size: CGFloat = 12,
                   color: Color = .black,
                   bold: Bool = false,
                   underline: Bool = false) -> Text {
        Text(content)
            .font(.custom("PingFangTC-Regular", size: size))
            .bold(bold)
            .underline(underline)
            .foregroundStyle(color)
    }
}

struct TypingText: View {

    @State private var displayedText: String = ""
    @State private var characterIndex: Int = 0
    private let typingSpeed: TimeInterval
    private let fullText: String
    private let size: CGFloat
    private let color: Color
    private let bold: Bool
    private let underline: Bool
    
    init(_ fullText: String,
         size: CGFloat = 12,
         color: Color = .black,
         bold: Bool = false,
         underline: Bool = false,
         typingSpeed: TimeInterval = 0.05)
        {
        self.fullText = fullText
        self.size = size
        self.color = color
        self.bold = bold
        self.underline = underline
        self.typingSpeed = typingSpeed
    }

    var body: some View {
        Text.BS(displayedText,
                size: size,
                color: color,
                bold: bold,
                underline: underline)
            .onAppear {
                startTyping()
            }
            .animation(.linear, value: displayedText)
    }
    
    private func startTyping() {
        displayedText = ""
        characterIndex = 0
        Timer.scheduledTimer(withTimeInterval: typingSpeed, repeats: true) { timer in
            if characterIndex < fullText.count {
                let index = fullText.index(fullText.startIndex, offsetBy: characterIndex)
                displayedText.append(fullText[index])
                characterIndex += 1
            } else {
                timer.invalidate()
            }
        }
    }
}


struct PulsingText: View {
    
    @State private var opacity: Double = 0.0
    private let text: String
    private let size: CGFloat
    private let color: Color
    private let bold: Bool
    private let underline: Bool
    private let pulsingSpeed: TimeInterval
    private let initialDelay: TimeInterval
    
    init(_ text: String,
         size: CGFloat = 12,
         color: Color = .black,
         bold: Bool = false,
         underline: Bool = false,
         pulsingSpeed: TimeInterval = 0.5,
         initialDelay: TimeInterval = 1.0)
        {
        self.text = text
        self.size = size
        self.color = color
        self.bold = bold
        self.underline = underline
        self.pulsingSpeed = pulsingSpeed
        self.initialDelay = initialDelay
    }
    
    var body: some View {
        Text.BS(text,
                size: size,
                color: color,
                bold: bold,
                underline: underline)
            .opacity(opacity)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + initialDelay) {
                    withAnimation(.easeIn(duration: pulsingSpeed)) {
                        opacity = 1.0
                    }
                    startPulsing()
                }
            }
    }
    
    private func startPulsing() {
        DispatchQueue.main.asyncAfter(deadline: .now() + pulsingSpeed) {
            withAnimation(.easeInOut(duration: pulsingSpeed).repeatForever(autoreverses: true)) {
                opacity = 0.1
            }
        }
    }

}
