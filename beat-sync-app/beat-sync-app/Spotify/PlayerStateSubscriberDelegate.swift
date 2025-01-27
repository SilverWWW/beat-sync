//
//  PlayerStateObserverDelegate.swift
//  beat-sync-app
//
//  Created by Will Silver on 1/20/25.
//

import Foundation

protocol PlayerStateSubscriberDelegate {
    
    func playerStateDidChange(_ newState: SPTAppRemotePlayerState)
    
    func playerDidDisconnect()
    
    func playerDidConnect()
    
}
