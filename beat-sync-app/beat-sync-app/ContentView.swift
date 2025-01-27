//
//  ContentView.swift
//  beat-sync-app
//
//  Created by Will Silver on 1/15/25.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var spotifyManager = SpotifyManager.shared
    
    @State private var showSplash = true
    
    var body: some View {
        if showSplash {
            LaunchSplashscreenView(onDoneShowingSplash: {
                DispatchQueue.main.async {
                    showSplash = false
                }
            })
        } else {
            NavigationStack {
                if spotifyManager.isAuthorized {
                    TabBarView()
                } else {
                    ProfileCreationView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
