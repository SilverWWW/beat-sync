//
//  UserViewModel.swift
//  SpotifyBeatSync
//
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

class UserViewModel: ObservableObject {
    
    static let shared = UserViewModel() // singleton pattern U+1F92F
    
    @Published var isLoading: Bool = true
    @Published var user: User? = nil
    @Published var isSpotifyLinked: Bool = false


    
    private init() { // private so that initializer is only called once
        NotificationCenter.default.addObserver(self, selector: #selector(handleSpotifyAuthCallback(_:)), name: .spotifyAuthCallback, object: nil)
        fetchUser()
    }
    
    @objc private func handleSpotifyAuthCallback(_ notification: Notification) {
        refreshUserState()
    }
    
    func refreshUserState() {
        fetchUser() // calls checkIfSpotifyLinked()
    }
    
    
    func fetchUser() {
        isLoading = true
        
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { [weak self] snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                self?.user = User(id: data["id"] as? String ?? "",
                                  name: data["name"] as? String ?? "",
                                  email: data["email"] as? String ?? "",
                                  joined: data["joined"] as? TimeInterval ?? 0)
                self?.checkIfSpotifyLinked()
                            }
        }
    }

    func logout() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    func linkSpotifyAccount() {
        guard let url = getSpotifyAuthURL() else { return }
        UIApplication.shared.open(url)
    }
    
    
    func getSpotifyAuthURL() -> URL? {
        let clientID = "f27c4f7d1dee42f588915fecb5cb5081"
        let redirectURI = "spotifybeatsync://spotify-callback"
        let scopes = "user-read-private user-read-email user-library-read streaming user-read-currently-playing user-modify-playback-state playlist-read-private playlist-read-collaborative"

        var components = URLComponents()
        components.scheme = "https"
        components.host = "accounts.spotify.com"
        components.path = "/authorize"
        components.queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "scope", value: scopes),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "show_dialog", value: "true")
        ]
        
        return components.url
    }
    
    
    
    func checkIfSpotifyLinked() {
        guard let userId = user?.id else { return }

        let db = Firestore.firestore()
        db.collection("spotifyCredentials").document(userId).getDocument { [weak self] document, error in
            DispatchQueue.main.async {
                        self?.isSpotifyLinked = document != nil && document!.exists
                        self?.isLoading = false
                    }
        }
        
        // not loading anymore
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
    
    
}
