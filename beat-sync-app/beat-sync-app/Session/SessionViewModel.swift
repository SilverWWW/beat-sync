//
//  SessionViewModel.swift
//  beat-sync-app
//
//  Created by Will Silver on 1/20/25.
//

import Foundation
import Combine

class SessionViewModel: ObservableObject, PlayerStateSubscriberDelegate {
    
    @Published var isSheetPresented = false
    
    @Published private(set) var isPlaying: Bool = false
    @Published private(set) var currentTrack: SPTAppRemoteTrack?
    @Published private(set) var currentImage: UIImage?
    @Published private(set) var spotifyIsAsleep: Bool = false
    @Published private(set) var songProgress: Double = 0.0
    @Published private(set) var songContext: String = ""
    
    private var playbackTimer: AnyCancellable?
    private var lastKnownPlaybackPosition: Int = 0
    private var trackDuration: Int = 0
    private let updateInterval: TimeInterval = 0.1
    
    
    private let closeSessionCompletion: () -> Void
    
    private let silentURI = "spotify:track:3mkOlbSv5RYadx0JsjTrKq" // silent track
    
    init(closeSessionCompletion: @escaping () -> Void) {
        self.closeSessionCompletion = closeSessionCompletion
        SpotifyManager.subscribeToPlayerState(delegate: self)
    }
    
    func start() {
        SpotifyManager.shared.appRemote.authorizeAndPlayURI("")
    }
    
    func skipPrevious() {
        SpotifyManager.skipPreviousTrack(completion: {})
    }
    
    func skipNext() {
        SpotifyManager.skipNextTrack(completion: {})
    }
    
    func pauseOrResume()  {
        SpotifyManager.isPaused(completion: { isPaused in
            guard let paused = isPaused else { return }
            
            if paused {
                SpotifyManager.resumePlayback(completion: {})
            } else {
                SpotifyManager.pausePlayback(completion: {})
            }
        })
    }
    
    func syncUpButton() {
        DispatchQueue.main.async { [weak self] in
            self?.isSheetPresented = true
        }
    }
    
    func closeSyncSheet() {
        DispatchQueue.main.async { [weak self] in
            self?.isSheetPresented = false
        }
    }
    
    func didMeasureBPM(_ bpm: Int) {
        print("measured BPM: \(bpm)")
    }
    
    func playerStateDidChange(_ newState: SPTAppRemotePlayerState) {
        print("Player state changed: \(newState.track.name), id: \(newState.track.uri)")
        
        isPlaying = !newState.isPaused
        
        // update playback position
        lastKnownPlaybackPosition = newState.playbackPosition
        trackDuration = Int(newState.track.duration)
        updateSongProgress()
        managePlaybackTimer(isPlaying: isPlaying)
        
        // update track info if new
        let newTrack = self.currentTrack?.uri ?? "" != newState.track.uri
        self.currentTrack = newState.track
        if newTrack {
            updateImageForCurrentTrack()
        }
        
        // update the player state context
        DispatchQueue.main.async { [weak self] in
            self?.songContext = newState.contextTitle
        }
        
    }
    
    func updateSongProgress() {
        DispatchQueue.main.async { [weak self] in
            self?.songProgress = Double(self?.lastKnownPlaybackPosition ?? 0) / Double(self?.trackDuration ?? 0)
        }
    }
    
    func managePlaybackTimer(isPlaying: Bool) {
        if isPlaying {
            playbackTimer = Timer.publish(every: updateInterval, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    guard let self = self else { return }
                    self.incrementPlaybackPosition()
                }
        } else {
            playbackTimer?.cancel()
            playbackTimer = nil
        }
    }
    
    private func incrementPlaybackPosition() {
        guard trackDuration > 0 else { return }
        lastKnownPlaybackPosition += Int(updateInterval * 1000) // milliseconds

        if lastKnownPlaybackPosition >= trackDuration {
            lastKnownPlaybackPosition = trackDuration
            managePlaybackTimer(isPlaying: false)
        }
        updateSongProgress()
    }
    
    func updateImageForCurrentTrack() {
        guard let track = currentTrack else {
            return
        }
        let size = CGSize(width: 1000, height: 1000)
        SpotifyManager.getImageFromRepresentable(track, size: size, completion: { [weak self] image in
            DispatchQueue.main.async { [weak self] in
                self?.currentImage = image
            }
        })
    }
    
    func playerDidDisconnect() {
        DispatchQueue.main.async { [weak self] in
            self?.spotifyIsAsleep = true
        }
    }
    
    func playerDidConnect() {
        DispatchQueue.main.async { [weak self] in
            self?.spotifyIsAsleep = false
        }
    }
    
    func closeSession() {
        if isPlaying {
            SpotifyManager.pausePlayback(completion: {})
        }
        SpotifyManager.shared.appRemote.disconnect()
        closeSessionCompletion()
    }
}
