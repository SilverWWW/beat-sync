//
//  beat_sync_appApp.swift
//  beat-sync-app
//
//  Created by Will Silver on 1/15/25.
//

import SwiftUI

@main
struct beat_sync_appApp: App {
    
    @Environment(\.scenePhase) private var scenePhase
        
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
                .onOpenURL { url in
                    Task {
                        await SpotifyManager.handleSpotifyRedirect(url: url)
                    }
                }
                .onChange(of: scenePhase) { _ , newPhase in
                    self.handleScenePhaseChange(newPhase)
                }
                .onAppear {
                    Task {
                        if let accessToken = KeychainHelper.read(key: "access_token"),
                           let refreshToken = KeychainHelper.read(key: "refresh_token") {
                            
                            if SpotifyManager.isTokenExpiringOrExpired() {
                                do {
                                    try await SpotifyManager.refreshAccessToken(refreshToken: refreshToken)
                                } catch {
                                    print("Could not refresh access token", error.localizedDescription)
                                }
                            } else {
                                print("access token: ", accessToken)
                                SpotifyManager.refreshAccessTokenFromKeychain(accessToken: accessToken)
                            }
                        }
                    }
                }
        }
    }
    
    private func handleScenePhaseChange(_ newPhase: ScenePhase) {
        switch newPhase {
        case .active:
            if let _ = SpotifyManager.shared.appRemote.connectionParameters.accessToken {
                SpotifyManager.shared.appRemote.connect()
            }
        case .inactive:
            break
        case .background:
            if SpotifyManager.shared.appRemote.isConnected {
                SpotifyManager.shared.appRemote.disconnect()
            }
        @unknown default:
            break
        }
    }
}
