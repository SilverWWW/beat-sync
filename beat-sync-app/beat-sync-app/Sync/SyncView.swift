//
//  SyncView.swift
//  beat-sync-app
//
//  Created by Will Silver on 1/21/25.
//

import SwiftUI

struct SyncView: View {
    
    @StateObject private var viewModel: SyncViewModel
            
    init(closeSyncView: @escaping () -> (Void), didMeasureBPM: @escaping (Int) -> (Void)) {
        _viewModel = StateObject(wrappedValue: SyncViewModel(closeSyncView: closeSyncView, didMeasureBPM: didMeasureBPM))
    }
    
    private let horizontalPadding = CGFloat(24)
    
    var body: some View {
        ZStack {
            
            RippleTapView(screenTappedCallback: viewModel.screenTapped)
            
            VStack {
                closeSync
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, 24)
                    .padding(.bottom, 12)
                
                Text.BS("Tap anywhere on the screen to the beat of your footsteps!",
                        size: 32,
                        color: BSColor.beatsyncDark,
                        bold: true)
                .padding(.bottom, 48)
                
                Spacer()
            }
        }
        .onAppear {
            viewModel.resetData()
        }
    }
    
    
    var closeSync: some View {
        HStack {
            Spacer()
            Button(action: viewModel.closeSync) {
                Image.BS(systemName: "xmark", color: BSColor.beatsyncDark)
                    .frame(width: 24, height: 24)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
}

import SwiftUI

struct RippleTapView: View {

    struct Ripple: Identifiable {
        let id = UUID()
        let center: CGPoint
        let startTime: Date
    }
    
    private let screenTappedCallback: (UInt64) -> Void
    
    init(screenTappedCallback: @escaping (UInt64) -> Void) {
        self.screenTappedCallback = screenTappedCallback
    }
    
    @State private var ripples: [Ripple] = []
    
    private let rippleDuration: TimeInterval = 1.0
    private let maxRadius: CGFloat = 250
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let now = timeline.date
                
                for ripple in ripples {
                    let elapsed = now.timeIntervalSince(ripple.startTime)
                    
                    guard elapsed <= rippleDuration else {
                        continue
                    }
                    
                    let progress = CGFloat(elapsed / rippleDuration)
                    let radius = progress * maxRadius
                    let alpha = 1 - progress
                    let gradient = Gradient(colors: [
                        BSColor.beatsyncDark.opacity(Double(alpha)),
                        Color.clear
                    ])
                    let shading = GraphicsContext.Shading.radialGradient(
                        gradient,
                        center: ripple.center,
                        startRadius: 0,
                        endRadius: radius
                    )
                    
                    let circlePath = Path(ellipseIn: CGRect(
                        x: ripple.center.x - radius,
                        y: ripple.center.y - radius,
                        width: radius * 2,
                        height: radius * 2
                    ))
                    
                    context.fill(circlePath, with: shading)
                }
            }
        }
        .ignoresSafeArea()
        .onTapGesture { location in
            screenTappedCallback(DispatchTime.now().uptimeNanoseconds)
            addRipple(at: location)
        }
        .onReceive(Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()) { _ in
            cleanUpRipples()
        }
    }
    
    private func addRipple(at location: CGPoint) {
        let newRipple = Ripple(center: location, startTime: Date())
        ripples.append(newRipple)
    }
    
    private func cleanUpRipples() {
        let now = Date()
        ripples.removeAll {
            now.timeIntervalSince($0.startTime) > rippleDuration
        }
    }
}


#Preview {
    SyncView(closeSyncView: {}, didMeasureBPM: { _ in
    })
}
