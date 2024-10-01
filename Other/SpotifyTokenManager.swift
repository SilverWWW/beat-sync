//
//  SpotifyTokenManager.swift
//  SpotifyBeatSync
//
//


import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseCore


class SpotifyTokenManager {
    
    static var shared: SpotifyTokenManager = {
        FirebaseApp.configure()
        return SpotifyTokenManager()
    }()
    
    private let db = Firestore.firestore()
    
    var accessToken: String = ""
    var refreshToken: String = ""
    var tokenExpiryTime: TimeInterval = 1.0
    
    private init() {
    }
    
    
    
    // called before making api calls to spotify
    func refreshAccessTokenIfNeeded(completion: @escaping (Bool) -> Void) {
        
        fetchTokenData { [weak self] success in
            guard success else {
                print("Could not fetch data")
                completion(false)
                return
            }
    
        
            guard let self = self else {
                completion(false)
                return
            }
        
            if Date().timeIntervalSince1970 < (self.tokenExpiryTime - 100.0) { // buffer
                completion(true)
            } else {
                self.refreshAccessToken(completion: completion)
            }
        }
    }
    
    
    
    // called when the user logs in to initially load in token data
    func fetchTokenData(completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        
        db.collection("spotifyCredentials").document(userId).getDocument { [weak self] document, error in
            guard let self = self, let document = document, error == nil else {
                completion(false)
                return
            }
            
            guard let accessToken = document.data()?["accessToken"] as? String,
                  let refreshToken = document.data()?["refreshToken"] as? String,
                  let expiryTimestamp = document.data()?["expiryDate"] as? Double else {
                    
                completion(false)
                return
            }
            
            self.accessToken = accessToken
            self.refreshToken = refreshToken
            self.tokenExpiryTime = expiryTimestamp
            
            completion(true)
        }
    }
    
    private func storeTokenData(accessToken: String, refreshToken: String, expiryDate: TimeInterval) {
        let credentials = SpotifyCredentials(accessToken: accessToken, refreshToken: refreshToken, expiryDate: expiryDate)
        let credentialsDictionary = credentials.asDictionary()

        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Could not fetch user id")
            return
        }

        db.collection("spotifyCredentials").document(userId).setData(credentialsDictionary) { error in
            if let error = error {
                print("Error storing Spotify credentials: \(error)")
            }
        }
    }

    private func fetchTokenExpiryDate(completion: @escaping (TimeInterval?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(nil)
            return
        }

        db.collection("spotifyCredentials").document(userId).getDocument { document, error in
            guard let document = document, error == nil else {
                completion(nil)
                return
            }

            if let expiryDate = document.data()?["expiryDate"] as? TimeInterval {
                completion(expiryDate)
            } else {
                completion(nil)
            }
        }
    }

    
    
    private func refreshAccessToken(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://accounts.spotify.com/api/token") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        
        guard let client_id = Bundle.main.infoDictionary?["CLIENT_ID"] as? String,
              let client_secret = Bundle.main.infoDictionary?["CLIENT_SECRET"] as? String else {
            fatalError("CLIENT_ID or CLIENT_SECRET not found")
        }
        
        // Prepare the data to be sent in the request body
        let parameters: [String: String] = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken,
            "client_id": client_id,
            "client_secret": client_secret
        ]

        // Encode the parameters as URL encoded string
        request.httpBody = parameters
            .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)" }
            .joined(separator: "&")
            .data(using: .utf8)

        // Set the content type of your request
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }

            do {
                // Parse the JSON data and extract the new access token
                let responseObject = try JSONDecoder().decode(SpotifyRefreshTokenResponse.self, from: data)
                DispatchQueue.main.async {
                    
                    guard let strongSelf = self else {
                            completion(false)
                            return
                        }
                    
                    strongSelf.accessToken = responseObject.accessToken
                    strongSelf.tokenExpiryTime = Date().timeIntervalSince1970 + Double(responseObject.expiresIn)
                    
                    
                    // Store these tokens securely (e.g., in Keychain)
                    self?.storeTokenData(accessToken: strongSelf.accessToken,
                                                 refreshToken: strongSelf.refreshToken,
                                                 expiryDate: strongSelf.tokenExpiryTime)
                    
                    completion(true)
                }
            } catch {
                completion(false)
            }
        }.resume()
    }
    
    func exchangeAuthCodeForTokens(code: String) {
        
        guard let client_id = Bundle.main.infoDictionary?["CLIENT_ID"] as? String,
              let client_secret = Bundle.main.infoDictionary?["CLIENT_SECRET"] as? String else {
            fatalError("CLIENT_ID or CLIENT_SECRET not found")
        }
        
        let tokenURL = "https://accounts.spotify.com/api/token"
        var request = URLRequest(url: URL(string: tokenURL)!)
        request.httpMethod = "POST"

        let bodyParameters = "grant_type=authorization_code&code=\(code)&redirect_uri=spotifybeatsync://spotify-callback&client_id=\(client_id)&client_secret=\(client_secret)"
        
        request.httpBody = bodyParameters.data(using: .utf8)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        // Perform the request
        URLSession.shared.dataTask(with: request) { data, response, error in
                self.handleAuthTokenResponse(data: data, response: response, error: error)
            }.resume()
    }
    
    
    func handleAuthTokenResponse(data: Data?, response: URLResponse?, error: Error?) {
        if let error = error {
            print("Error occurred: \(error)")
            return
        }

        // Parse the response data
        if let data = data {
            do {
                let decoder = JSONDecoder()
                let tokenResponse = try decoder.decode(SpotifyAuthTokenResponse.self, from: data)
                let accessToken = tokenResponse.accessToken
                let refreshToken = tokenResponse.refreshToken
                let expiryDate = Date().timeIntervalSince1970 + Double(tokenResponse.expiresIn)
                                
                // Store these tokens securely (e.g., in Keychain)
                storeTokenData(accessToken: accessToken, refreshToken: refreshToken, expiryDate: expiryDate)
                
            } catch {
                print("Error decoding response: \(error)")
            }
        }
    }
    
    
}
    



struct SpotifyRefreshTokenResponse: Codable {
    let accessToken: String
    let expiresIn: Int

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
    }
}

struct SpotifyAuthTokenResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
    }
}


struct SpotifyCredentials: Codable {
    var accessToken: String
    var refreshToken: String
    var expiryDate: TimeInterval
}

