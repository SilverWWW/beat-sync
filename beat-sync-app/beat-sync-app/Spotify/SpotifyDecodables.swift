//
//  SpotifyDecodables.swift
//  beat-sync-app
//
//  Created by Will Silver on 1/25/25.
//

import Foundation


struct TokenResponse: Decodable {
    let access_token: String
    let refresh_token: String
    let expires_in: Int
}

struct RefreshResponse: Decodable {
    let access_token: String
    let expires_in: Int
}
