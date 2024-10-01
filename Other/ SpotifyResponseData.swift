//
//  SpotifyCurrentlyPlayingResponse.swift
//  SpotifyBeatSync
//
//

import Foundation

struct SpotifyArtist: Codable {
    let name: String
    // Add other artist properties as needed...
}

struct Album: Codable {
    let images: [Image]
    
    struct Image: Codable {
        let url: String
        let height: Int?
        let width: Int?
    }
}

struct SpotifyTrack: Codable {
    let name: String
    let artists: [SpotifyArtist]
    let album: Album
    let id: String
    // Add other track properties as needed...
}

struct SpotifyCurrentlyPlayingResponse: Codable {
    let item: SpotifyTrack?
    let isPlaying: Bool
    
    enum CodingKeys: String, CodingKey {
            case item
            case isPlaying = "is_playing"
        }
}

struct SpotifyPlaylistTracksResponse: Codable {
    let items: [PlaylistTrackItem]

    struct PlaylistTrackItem: Codable {
        let track: SpotifyTrack
    }
}

struct SpotifyTrackInfoResponse: Codable {
    let audioFeatures: AudioFeatures

    enum CodingKeys: String, CodingKey {
        case audioFeatures = "audio_features"
    }

    struct AudioFeatures: Codable {
        let tempo: Float
        // Add other audio feature properties as needed...
    }
}

struct SpotifyPlaylistResponse: Codable {
    let items: [SpotifyPlaylist]
    // Include other response properties if needed.

    struct SpotifyPlaylist: Codable, Hashable {
        let id: String
        let name: String
        // Add other playlist properties as needed.
        
        // Implement the hashable requirement
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
}




