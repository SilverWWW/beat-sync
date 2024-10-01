//
//  SpotifyTempoQueue.swift
//  SpotifyBeatSync
//
//

import Foundation


class SpotifyTempoQueue {
    
    private let spotifyRequest = SpotifyRequest()
    private let targetBPM: Float
    private var matchingTracks: [String] = []
    
    init(targetBPM: Float) {
        self.targetBPM = targetBPM
    }
    
    
}
