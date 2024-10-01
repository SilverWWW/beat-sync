//
//  AppDelegate.swift
//  SpotifyBeatSync
//
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseCore




class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private let tokenManager = SpotifyTokenManager.shared
    
    
    // temporary solution
    func handleURL(url: URL) {
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else { return }
        
        if let code = queryItems.first(where: { $0.name == "code" })?.value {
            tokenManager.exchangeAuthCodeForTokens(code: code)
        }
        
        // notify the profile view to refresh
        NotificationCenter.default.post(name: .spotifyAuthCallback, object: url)
    }
    
    
    
    // stil doesn't get called on app open
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

        /*
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else { return false }

        if let code = queryItems.first(where: { $0.name == "code" })?.value {
            tokenManager.exchangeAuthCodeForTokens(code: code)
        }
        */
         
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //FirebaseApp.configure()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state
        /*
        if (self.appRemote.isConnected) {
            [self.appRemote disconnect];
        } */
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        /*
        if (self.appRemote.connectionParameters.accessToken) {
            [self.appRemote connect];
        } */
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers...
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state...
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate...
    }



}
