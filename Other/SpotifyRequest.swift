//
//  SpotifyRequest.swift
//  SpotifyBeatSync
//
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class SpotifyRequest {
    
    private let tokenManager = SpotifyTokenManager.shared
    
        
    func getCurrentPlayingTrack(completion: @escaping (Result<(SpotifyTrack, Bool), Error>) -> Void) {
        tokenManager.refreshAccessTokenIfNeeded { success in
            guard success, !self.tokenManager.accessToken.isEmpty else {
                completion(.failure(NSError(domain: "SpotifyRequest", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to refresh access token or access token is unavailable"])))
                return
            }

            let accessToken = self.tokenManager.accessToken

            // Prepare the request to Spotify API
            let url = URL(string: "https://api.spotify.com/v1/me/player/currently-playing")!
            var request = URLRequest(url: url)
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

            // Perform the request
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    completion(.failure(NSError(domain: "SpotifyRequest", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received or invalid response"])))
                    return
                }

                do {
                    let currentlyPlayingResponse = try JSONDecoder().decode(SpotifyCurrentlyPlayingResponse.self, from: data)
                    if let track = currentlyPlayingResponse.item {
                        completion(.success((track, currentlyPlayingResponse.isPlaying)))
                    } else {
                        completion(.failure(NSError(domain: "SpotifyRequest", code: 1, userInfo: [NSLocalizedDescriptionKey: "Track data not found"])))
                    }
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }
    }

    
    func skipToNextTrack(completion: @escaping (Result<Void, Error>) -> Void) {
        sendControlRequest(to: "next", method: "POST", completion: completion)
    }

    func pausePlayback(completion: @escaping (Result<Void, Error>) -> Void) {
        sendControlRequest(to: "pause", method: "PUT", completion: completion)
    }
    
    func resumePlayback(completion: @escaping (Result<Void, Error>) -> Void) {
        sendControlRequest(to: "play", method: "PUT", completion: completion)
    }

    func playPreviousTrack(completion: @escaping (Result<Void, Error>) -> Void) {
        sendControlRequest(to: "previous", method: "POST", completion: completion)
    }
    
    
    private func sendControlRequest(to endpoint: String, method: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
        tokenManager.refreshAccessTokenIfNeeded { success in
            guard success, !self.tokenManager.accessToken.isEmpty else {
                completion(.failure(NSError(domain: "SpotifyRequest", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to refresh access token or access token is unavailable"])))
                return
            }
            
            let accessToken = self.tokenManager.accessToken
            
            guard let url = URL(string: "https://api.spotify.com/v1/me/player/\(endpoint)") else {
                completion(.failure(NSError(domain: "SpotifyControlRequest", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = method
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: request) { _, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 {
                    completion(.success(()))
                } else {
                    completion(.failure(NSError(domain: "SpotifyControlRequest", code: 0, userInfo: [NSLocalizedDescriptionKey: "Spotify API request failed"])))
                }
            }.resume()
        }
    }
    
    
    
    func getTrackInfo(id: String, completion: @escaping (Result<SpotifyTrackInfoResponse.AudioFeatures, Error>) -> Void) {
        
        tokenManager.refreshAccessTokenIfNeeded { success in
            guard success, !self.tokenManager.accessToken.isEmpty else {
                completion(.failure(NSError(domain: "SpotifyRequest", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to refresh access token or access token is unavailable"])))
                return
            }
            
            let accessToken = self.tokenManager.accessToken
            
            guard let url = URL(string: "https://api.spotify.com/v1/audio-features/\(id)") else {
                completion(.failure(NSError(domain: "SpotifyRequest", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
                return
            }
            
            var request = URLRequest(url: url)
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    completion(.failure(NSError(domain: "SpotifyRequest", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received or invalid response"])))
                    return
                }
                
                do {
                    let audioFeatures = try JSONDecoder().decode(SpotifyTrackInfoResponse.AudioFeatures.self, from: data)
                    completion(.success(audioFeatures))
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }
    }
    
    
    func queueTrack(trackId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        tokenManager.refreshAccessTokenIfNeeded { success in
            guard success, !self.tokenManager.accessToken.isEmpty else {
                completion(.failure(NSError(domain: "SpotifyRequest", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to refresh access token or access token is unavailable"])))
                return
            }

            let accessToken = self.tokenManager.accessToken
            let url = URL(string: "https://api.spotify.com/v1/me/player/queue?uri=spotify:track:\(trackId)")!

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

            URLSession.shared.dataTask(with: request) { _, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 else {
                    completion(.failure(NSError(domain: "SpotifyRequest", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to queue track"])))
                    return
                }
                completion(.success(()))
            }.resume()
        }
    }
    
    
    func getUserPlaylists(completion: @escaping (Result<[SpotifyPlaylistResponse.SpotifyPlaylist], Error>) -> Void) {
        tokenManager.refreshAccessTokenIfNeeded { success in
            guard success, !self.tokenManager.accessToken.isEmpty else {
                completion(.failure(NSError(domain: "SpotifyRequest", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to refresh access token or access token is unavailable"])))
                return
            }

            let accessToken = self.tokenManager.accessToken
            let url = URL(string: "https://api.spotify.com/v1/me/playlists")!

            var request = URLRequest(url: url)
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    completion(.failure(NSError(domain: "SpotifyRequest", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received or invalid response"])))
                    return
                }

                do {
                    let playlistResponse = try JSONDecoder().decode(SpotifyPlaylistResponse.self, from: data)
                    completion(.success(playlistResponse.items))
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }
    }
    
    func shufflePlaylistTracks(playlistId: String, completion: @escaping (Result<[SpotifyTrack], Error>) -> Void) {
        tokenManager.refreshAccessTokenIfNeeded { success in
            guard success, !self.tokenManager.accessToken.isEmpty else {
                completion(.failure(NSError(domain: "SpotifyRequest", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to refresh access token or access token is unavailable"])))
                return
            }

            let accessToken = self.tokenManager.accessToken
            self.getPlaylistTracks(playlistId: playlistId, accessToken: accessToken, completion: completion)
        }
    }


    private func getPlaylistTracks(playlistId: String, accessToken: String, completion: @escaping (Result<[SpotifyTrack], Error>) -> Void) {
        guard let url = URL(string: "https://api.spotify.com/v1/playlists/\(playlistId)/tracks") else {
            completion(.failure(NSError(domain: "SpotifyRequest", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "SpotifyRequest", code: 2, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            do {
                let playlistResponse = try JSONDecoder().decode(SpotifyPlaylistTracksResponse.self, from: data)
                let tracks = playlistResponse.items.map { $0.track }
                let shuffledTracks = tracks.shuffled() // This shuffles the tracks
                completion(.success(shuffledTracks))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}


