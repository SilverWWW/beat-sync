//
//  ProfileViewModel.swift
//  beat-sync-app
//
//  Created by Will Silver on 1/19/25.
//

import Foundation

class ProfileViewModel: ObservableObject {
    
    
    func clearUserData() {
        KeychainHelper.delete(key: "refresh_token")
        KeychainHelper.delete(key: "access_token")
        KeychainHelper.delete(key: "access_token_expires_in")
        SpotifyManager.shared.isAuthorized = false
    }
}
