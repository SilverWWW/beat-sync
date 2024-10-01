//
//  SessionViewViewModel.swift
//  SpotifyBeatSync
//
//

import Foundation


class SessionViewViewModel: ObservableObject {
    
    @Published var isPlaying = true
    @Published var currentSong: String = "Nothing Playing"
    @Published var currentArtist: String = "N/A"
    @Published var currentImgURL: String = "https://i.scdn.co/image/ab67616d00001e02ff9ca10b55ce82ae553c8228"
    @Published var currentTrackID: String = ""
    @Published var currentBPM: Int = 0
    @Published var allUserPlaylists: [SpotifyPlaylistResponse.SpotifyPlaylist] = []
    @Published var currentPlaylist: SpotifyPlaylistResponse.SpotifyPlaylist?
    
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var isPlaybackStarted = false

    
    func nextSong() {
        isPlaying = true
        let spotifyRequest = SpotifyRequest()
        
        spotifyRequest.skipToNextTrack { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print(error)
                    self.showAlert = true
                    self.alertMessage = "Pease open Spotify and begin playing any song."
                case .success():
                    self.getCurrentlyPlaying()
                }
            }
        }
    }
    
    func previousSong() {
        isPlaying = true
        let spotifyRequest = SpotifyRequest()
        
        spotifyRequest.playPreviousTrack { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print(error)
                    self.showAlert = true
                    self.alertMessage = "Pease open Spotify and begin playing any song."
                case .success():
                    self.getCurrentlyPlaying()
                }
            }
        }
    }
    
    
    func playback() {
        
        let spotifyRequest = SpotifyRequest()
        
        if isPlaying {
            spotifyRequest.pausePlayback { result in
                DispatchQueue.main.async {
                    switch result {
                    case .failure(let error):
                        print(error)
                        self.showAlert = true
                        self.alertMessage = "Pease open Spotify and begin playing any song."
                    case .success():
                        self.isPlaying = false
                    }
                }
            }
        } else {
            spotifyRequest.resumePlayback { result in
                DispatchQueue.main.async {
                    switch result {
                    case .failure(let error):
                        print(error)
                        self.showAlert = true
                        self.alertMessage = "Pease open Spotify and begin playing any song."
                    case .success():
                        self.isPlaying = true
                    }
                }
            }
        }
    }
    
    
    // called in get currently playing
    func calculateCurrentTargetBPM() {
        
        let spotifyRequest = SpotifyRequest()
        
        spotifyRequest.getTrackInfo(id: self.currentTrackID) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print("Error: \(error)")
                case .success(let audioFeatures):
                    self.currentBPM = Int(audioFeatures.tempo.rounded())
                }
            }
        }
        
    }
    
    
    func reSyncUp() {
        getCurrentlyPlaying()
    }
    
    
    func playShuffledPlaylist(playlistId: String) {
        let spotifyRequest = SpotifyRequest()

        // reset the playback started flag
        self.isPlaybackStarted = false

        spotifyRequest.shufflePlaylistTracks(playlistId: playlistId) { [weak self] result in
            switch result {
            case .success(let shuffledTracks):
                self?.queueNextTrack(shuffledTracks, 0, with: spotifyRequest, queuedCount: 0)
            case .failure(let error):
                print("Failed to shuffle playlist: \(error)")
                self?.showAlert = true
                self?.alertMessage = "Failed to shuffle playlist."
            }
        }
    }

    
    private func queueNextTrack(_ tracks: [SpotifyTrack], _ index: Int, with spotifyRequest: SpotifyRequest, queuedCount: Int) {
        let startPlaybackThreshold = 1 // Number of tracks to queue before starting playback
        let track = tracks[index]
        spotifyRequest.queueTrack(trackId: track.id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    print("Track \(track.name) added to queue")
                    let newQueuedCount = queuedCount + 1
                    // Check if playback should start and ensure it hasn't started yet
                    if newQueuedCount >= startPlaybackThreshold && !(self?.isPlaybackStarted ?? true) {
                        self?.startPlayback(with: spotifyRequest)
                        self?.isPlaybackStarted = true // Set the flag to true to avoid multiple playback starts
                    }
                    // Queue next track if there are more tracks left
                    if index < tracks.count - 1 {
                        self?.queueNextTrack(tracks, index + 1, with: spotifyRequest, queuedCount: newQueuedCount)
                    }
                case .failure(let error):
                    print("Failed to queue track: \(error)")
                    self?.showAlert = true
                    self?.alertMessage = "Failed to queue track."
                }
            }
        }
    }



    
    private func startPlayback(with spotifyRequest: SpotifyRequest) {
        spotifyRequest.skipToNextTrack { [weak self] result in
            switch result {
            case .success():
                print("Playback started")
                self?.getCurrentlyPlaying()
            case .failure(let error):
                print("Failed to start playback: \(error)")
                self?.showAlert = true
                self?.alertMessage = "Failed to start playback."
            }
        }
    }
    
    
    
    
    func getCurrentlyPlaying() {
        let maxAttempts = 3
        var currentAttempt = 0

        func attemptFetch() {
            let spotifyRequest = SpotifyRequest()

            spotifyRequest.getCurrentPlayingTrack { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let playingInfo):
                        if playingInfo.0.name != self?.currentSong {
                            self?.updateCurrentPlayingTrack(track: playingInfo.0, isPlaying: playingInfo.1)
                            return
                        }
                        
                        // If the track hasn't changed, try again after a delay
                        if currentAttempt < maxAttempts {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                currentAttempt += 1
                                attemptFetch()
                            }
                        }
                    case .failure(let error):
                        print(error)
                        self?.showAlert = true
                        self?.alertMessage = "Pease open Spotify and begin playing any song."
                    }
                }
            }
        }

        attemptFetch()
    }
    
    
    private func updateCurrentPlayingTrack(track: SpotifyTrack, isPlaying: Bool) {
        self.currentTrackID = track.id
        currentSong = track.name
        currentArtist = track.artists.first?.name ?? "N/A"
        currentImgURL = track.album.images.first?.url ?? "Default Image URL"
        self.calculateCurrentTargetBPM()
        self.isPlaying = isPlaying
    }
    
    
    func fetchUserPlaylists() {
        let spotifyRequest = SpotifyRequest()
        spotifyRequest.getUserPlaylists { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let playlists):
                    self?.allUserPlaylists = playlists
                case .failure(let error):
                    print("Error fetching playlists: \(error)")
                }
            }
        }
    }
    
    
    
    
    
    
}
