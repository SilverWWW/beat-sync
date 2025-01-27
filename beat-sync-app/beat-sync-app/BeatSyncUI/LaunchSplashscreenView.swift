//
//  LaunchSplashscreenView.swift
//  beat-sync-app
//
//  Created by Will Silver on 1/19/25.
//

import SwiftUI

struct LaunchSplashscreenView: View {
    
    @ObservedObject var spotifyManager = SpotifyManager.shared
    
    @State private var showLoadingAccessToken = false
    @State private var doneShowingSplash = false
    
    private let closeSplash: () -> (Void)
    private let durationShowingSplash: Double = 1.5
    
    init(onDoneShowingSplash: @escaping () -> (Void)) {
        self.closeSplash = onDoneShowingSplash
    }
    
    var body: some View {
        
        ZStack(alignment: .center) {
                        
            Image.BS("beat-sync-logo", color: BSColor.beatsyncDark)
                .frame(width: 500, height: 250)
            
            
            if showLoadingAccessToken {
                VStack(spacing: 4) {
                    Text.BS("Loading authentication...", color: BSColor.beatsyncDark)
                    ProgressView()
                        .tint(BSColor.beatsyncDark)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + durationShowingSplash) {
                doneShowingSplash = true
        
                if spotifyManager.isFetchingAcccessToken {
                    showLoadingAccessToken = true
                } else {
                    closeSplash()
                }
            }
        }
        .onChange(of: spotifyManager.isFetchingAcccessToken) { _, isFetching in
            if !isFetching && doneShowingSplash {
                closeSplash()
            }
        }
    }
}

#Preview {
    LaunchSplashscreenView(onDoneShowingSplash: {})
}
