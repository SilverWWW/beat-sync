//
//  SpotifyAuthManager.swift
//  beat-sync-app
//
//  Created by Will Silver on 1/17/25.
//

import Foundation

class SpotifyManager: NSObject, ObservableObject {
    
    @Published var isAuthorized: Bool = false
    @Published var isFetchingAcccessToken: Bool = false
    
    // singleton
    static let shared = SpotifyManager()
    
    private let spotifyClientID = "f27c4f7d1dee42f588915fecb5cb5081"
    private let spotifyRedirectURL = URL(string: "beatsync://spotify-login-callback")!
    
    private let tokenSwapURL = URL(string: "https://spotify-token-backend.onrender.com/api/token")!
    private let tokenRefreshURL = URL(string: "https://spotify-token-backend.onrender.com/api/refresh")!
        
    lazy var configuration: SPTConfiguration = {
        let config = SPTConfiguration(clientID: spotifyClientID, redirectURL: spotifyRedirectURL)
        config.tokenSwapURL = tokenSwapURL
        config.tokenRefreshURL = tokenRefreshURL
        config.playURI = playURI
        return config
    }()
    
    /// only used as a convenient way to initiate authentication for first-time users, i.e. by calling initiateSession()
    /// does not actually manage user sessions, do that manually instead
    lazy var sessionManager: SPTSessionManager = {
        SPTSessionManager(configuration: configuration, delegate: self)
    }()
    
    lazy var appRemote: SPTAppRemote = {
      let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
      appRemote.delegate = self
      return appRemote
    }()
    
    private let playURI = ""
    
    private var playerStateObservers = [PlayerStateSubscriberDelegate]()

    override private init() {}
}

// manages app remote playback + app remote information fetching
extension SpotifyManager {
    
    static func playTrack(uri: String, completion: @escaping () -> Void) {
        executeWithValidToken {
            guard SpotifyManager.shared.appRemote.isConnected else {
                completion()
                return
            }
            SpotifyManager.shared.appRemote.playerAPI?.play("spotify:track:\(uri)", callback: { _, error in
                if let error = error {
                    print("Error playing track: \(error.localizedDescription)")
                }
                completion()
            })
        }
    }
    
    static func pausePlayback(completion: @escaping () -> Void) {
        executeWithValidToken {
            guard SpotifyManager.shared.appRemote.isConnected else {
                completion()
                return
            }
            SpotifyManager.shared.appRemote.playerAPI?.pause({ _, error in
                if let error = error {
                    print("Error pausing track: \(error.localizedDescription)")
                }
                completion()
            })
        }
    }

    static func resumePlayback(completion: @escaping () -> Void) {
        executeWithValidToken {
            guard SpotifyManager.shared.appRemote.isConnected else {
                completion()
                return
            }
            SpotifyManager.shared.appRemote.playerAPI?.resume({ _, error in
                if let error = error {
                    print("Error resuming track: \(error.localizedDescription)")
                }
                completion()
            })
        }
    }
    
    static func skipNextTrack(completion: @escaping () -> Void)  {
        executeWithValidToken {
            guard SpotifyManager.shared.appRemote.isConnected else {
                completion()
                return
            }
            SpotifyManager.shared.appRemote.playerAPI?.skip(toNext: { _, error in
                if let error = error {
                    print("Error skipping to next track: \(error.localizedDescription)")
                }
                completion()
            })
        }
    }
    
    static func skipPreviousTrack(completion: @escaping () -> Void)  {
        executeWithValidToken {
            guard SpotifyManager.shared.appRemote.isConnected else {
                completion()
                return
            }
            SpotifyManager.shared.appRemote.playerAPI?.skip(toPrevious: { _, error in
                if let error = error {
                    print("Error skipping to previous track: \(error.localizedDescription)")
                }
                completion()
            })
        }
    }
    
    static func isPaused(completion: @escaping (Bool?) -> Void) {
        executeWithValidToken {
            guard SpotifyManager.shared.appRemote.isConnected else {
                completion(nil)
                return
            }
            SpotifyManager.shared.appRemote.playerAPI?.getPlayerState { (state, error) in
                if let error = error {
                    print(error)
                    completion(nil)
                } else if let state = state as? SPTAppRemotePlayerState {
                    completion(state.isPaused)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    static func getCurrentTrack(completion: @escaping (SPTAppRemoteTrack?) -> Void) {
        executeWithValidToken {
            guard SpotifyManager.shared.appRemote.isConnected else {
                completion(nil)
                return
            }
            SpotifyManager.shared.appRemote.playerAPI?.getPlayerState { (state, error) in
                if let error = error {
                    print(error)
                    completion(nil)
                } else if let state = state as? SPTAppRemotePlayerState {
                    completion(state.track)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    static func getPlaybackPosition(completion: @escaping (Int?) -> Void) {
        executeWithValidToken {
            guard SpotifyManager.shared.appRemote.isConnected else {
                completion(nil)
                return
            }
            SpotifyManager.shared.appRemote.playerAPI?.getPlayerState { (state, error) in
                if let error = error {
                    print(error)
                    completion(nil)
                } else if let state = state as? SPTAppRemotePlayerState {
                    completion(state.playbackPosition)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    static func getImageFromRepresentable(_ imageRepresentable: SPTAppRemoteImageRepresentable,
                                          size: CGSize,
                                          completion: @escaping (UIImage?) -> Void) {
        executeWithValidToken {
            guard SpotifyManager.shared.appRemote.isConnected else {
                completion(nil)
                return
            }
            SpotifyManager.shared.appRemote.imageAPI?.fetchImage(forItem: imageRepresentable, with: size) { result, error in
                if let error = error {
                    print(error)
                    completion(nil)
                } else if let result = result as? UIImage {
                    completion(result)
                } else {
                    completion(nil)
                }
            }
        }
    }
}

// manages app remote lifecycle
extension SpotifyManager: SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate {

    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        print("HERE: Connected App remote")
        SpotifyManager.shared.appRemote.playerAPI?.delegate = self
        SpotifyManager.shared.appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
        if let error = error {
          debugPrint(error.localizedDescription)
        }
      })
        for observer in playerStateObservers {
            observer.playerDidConnect()
        }
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: (any Error)?) {
        print("HERE: disconnected", error ?? "")
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: (any Error)?) {
        print("HERE: failed", error ?? "")
        for observer in SpotifyManager.shared.playerStateObservers {
            observer.playerDidDisconnect()
        }
    }
    
    func playerStateDidChange(_ playerState: any SPTAppRemotePlayerState) {
        for observer in SpotifyManager.shared.playerStateObservers {
            observer.playerStateDidChange(playerState)
        }
    }
    
    static func subscribeToPlayerState(delegate: PlayerStateSubscriberDelegate) {
        SpotifyManager.shared.playerStateObservers.append(delegate)
    }
}


// advanced authentication
extension SpotifyManager: SPTSessionManagerDelegate {
    
    
    static func connectSpotifyAaccount() {
        let scopes: SPTScope = [.appRemoteControl, .userLibraryRead, .playlistReadPrivate]
        SpotifyManager.shared.sessionManager.initiateSession(
            with: scopes,
            options: .default,
            campaign: "utm-campaign"
        )
    }
    
    static func handleSpotifyRedirect(url: URL) async {
        if let urlComponents = URLComponents(string: url.absoluteString) {
            if let code = urlComponents.queryItems?.first(where: { $0.name == "code" })?.value {
                do {
                    try await SpotifyManager.exchangeCodeForToken(code: code)
                    SpotifyManager.shared.appRemote.connect()
                } catch {
                    print("Error exchanging code for token:", error)
                }
            } else {
                print("Code parameter not found")
            }
        }
    }
    
    static func executeWithValidToken(_ action: @escaping () -> Void) {
        if isTokenExpiringOrExpired() {
            guard let refreshToken = KeychainHelper.read(key: "refresh_token") else {
                print("Refresh token not found. Could not complete action")
                return
            }
            Task {
                do {
                    try await refreshAccessToken(refreshToken: refreshToken)
                    action()
                } catch {
                    print("Error refreshing token: \(error)")
                    throw error
                }
            }
        } else {
            action()
        }
    }

    static func isTokenExpiringOrExpired() -> Bool {
        guard let expiryTimeString = KeychainHelper.read(key: "access_token_expires_in"),
              let expiryTime = ISO8601DateFormatter().date(from: expiryTimeString) else {
            return true // better to assume it's expired
        }
        let now = Date()
        let fiveMinutesFromNow = now.addingTimeInterval(5 * 60)
        if expiryTime <= fiveMinutesFromNow {
            return true
        } else {
            return false
        }
    }
    
    // called when we know we have a working access token already in the keychain
    @MainActor
    static func refreshAccessTokenFromKeychain(accessToken: String) {
        SpotifyManager.shared.isAuthorized = true
        SpotifyManager.shared.appRemote.connectionParameters.accessToken = accessToken
    }

    /// THESE FUNCTIONS SHOULD NEVER GET CALLED
    // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // //
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        print("This should never need to be called")
    }
    func sessionManager(manager: SPTSessionManager, didFailWith error: any Error) {
        print("This should never need to be called")
    }
    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        print("This should never need to be called")
    }
    // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // //
}

// token exchanges
extension SpotifyManager {
    
    @MainActor
    static func exchangeCodeForToken(code: String) async throws {
        SpotifyManager.shared.isFetchingAcccessToken = true
        let tokens = try await SpotifyWebAPIRequester.exchangeCodeForToken(code: code)
        print("Code successfully exchanged for access and refresh tokens.")
        handleAccessTokenReceived(tokens.accessToken, expiresIn: tokens.expiresIn)
        handleRefreshTokenReceived(tokens.refreshToken)
    }
    
    @MainActor
    static func refreshAccessToken(refreshToken: String) async throws {
        SpotifyManager.shared.isFetchingAcccessToken = true
        let tokens = try await SpotifyWebAPIRequester.refreshAccessToken(refreshToken: refreshToken)
        print("Access token successfully refreshed.")
        handleAccessTokenReceived(tokens.accessToken, expiresIn: tokens.expiresIn)
    }
    
    static private func handleAccessTokenReceived(_ accessToken: String, expiresIn: Int) {
        SpotifyManager.shared.isFetchingAcccessToken = false
        SpotifyManager.shared.isAuthorized = true
        SpotifyManager.shared.appRemote.connectionParameters.accessToken = accessToken
        
        let now = Date()
        let expiryTime = now.addingTimeInterval(TimeInterval(expiresIn))
        let dateFormatter = ISO8601DateFormatter()
        let expirationTimeString = dateFormatter.string(from: expiryTime)
        
        KeychainHelper.save(key: "access_token", value: accessToken)
        KeychainHelper.save(key: "access_token_expires_in", value: expirationTimeString)
    }
    
    static private func handleRefreshTokenReceived(_ refreshToken: String) {
        KeychainHelper.save(key: "refresh_token", value: refreshToken)
    }
}
