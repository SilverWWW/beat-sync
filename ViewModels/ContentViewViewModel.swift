//
//  ContentViewViewModel.swift
//  SpotifyBeatSync
//
//

import Foundation
import FirebaseAuth


class ContentViewViewModel: ObservableObject {
    
    @Published var currentUserID: String = ""
    private var handler: AuthStateDidChangeListenerHandle?

    init() {
        self.handler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUserID = user?.uid ?? ""
            }
        }
    }
    
    public var isSignedIn: Bool {
        Auth.auth().currentUser != nil
    }
    
}
