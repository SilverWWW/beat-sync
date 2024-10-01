//
//  SpotifyBeatSyncApp.swift
//  SpotifyBeatSync
//
//

import SwiftUI
import FirebaseCore


@main
struct SpotifyBeatSyncApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    appDelegate.handleURL(url: url)
                }
                
        }
    }
}
