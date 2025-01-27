//
//  ProfileCreationView.swift
//  beat-sync-app
//
//  Created by Will Silver on 1/19/25.
//

import SwiftUI

struct ProfileCreationView: View {
    
    @ObservedObject private var spotifyManager = SpotifyManager.shared
        
    @State var spotifyLinkOpacity = 0.0
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 32) {
            TypingText("Welcome!\nLet's get started...",
                       size: 34,
                       color: BSColor.beatsyncDark,
                       bold: true,
                       typingSpeed: 0.1)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 16)
            
            Button(action: SpotifyManager.connectSpotifyAaccount) {
                HStack {
                    Image.BS("spotify-logo", color: .white)
                        .frame(width: 30, height: 30)
                    
                    Text.BS("Link Spotify account",
                            size: 16,
                            color: .white,
                            bold: true)
                }
                .padding([.leading, .trailing], 8)
                .frame(height: 46)
                .background(BSColor.beatsyncDark)
                .cornerRadius(8)
            }
            .opacity(spotifyLinkOpacity)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation(.easeIn(duration: 0.3)) {
                        spotifyLinkOpacity = 1.0
                    }
                }
            }
            
            Spacer()
            
            if spotifyManager.isFetchingAcccessToken {
                VStack(alignment: .center, spacing: 4) {
                    Text.BS("Loading authentication...", color: BSColor.beatsyncDark)
                    ProgressView()
                        .tint(BSColor.beatsyncDark)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding([.leading, .trailing], 16)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ProfileCreationView()
}
