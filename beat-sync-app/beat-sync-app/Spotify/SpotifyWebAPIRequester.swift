//
//  SpotifyWebAPIRequester.swift
//  beat-sync-app
//
//  Created by Will Silver on 1/25/25.
//

import Foundation


actor SpotifyWebAPIRequester {
    
    static let shared = SpotifyWebAPIRequester()
    
    private static let baseURL = "https://spotify-token-backend.onrender.com/api"
    
    private init() {}
        
    // abstract get request method
    static private func getRequest<T: Decodable>(endpoint: String, queryParameters: [String: String]? = nil) async throws -> T {
        
        var urlComponents = URLComponents(string: "\(baseURL)\(endpoint)")
        if let queryParameters = queryParameters {
            urlComponents?.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let url = urlComponents?.url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decodedResponse = try JSONDecoder().decode(T.self, from: data)
        return decodedResponse
    }
    
    // abstract post request method
    static private func postRequest<T: Decodable>(endpoint: String, body: [String: String]?) async throws -> T {
        
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw URLError(.badURL)
        }
    
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        if let body = body {
            request.httpBody = body
                .map { "\($0.key)=\($0.value)" }
                .joined(separator: "&")
                .data(using: .utf8)
        }
        
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decodedResponse = try JSONDecoder().decode(T.self, from: data)
        return decodedResponse
    }
    
    @MainActor
    static func exchangeCodeForToken(code: String) async throws -> (accessToken: String, expiresIn: Int, refreshToken: String) {
        do {
            let tokenResponse: TokenResponse = try await postRequest(endpoint: "/token", body: ["code": code])
            return (tokenResponse.access_token, tokenResponse.expires_in, tokenResponse.refresh_token)
        } catch {
            print("Could not exchange code for access and refresh tokens: '\(error)")
            throw error
        }
    }
    
    @MainActor
    static func refreshAccessToken(refreshToken: String) async throws -> (accessToken: String, expiresIn: Int) {
        do {
            let refreshResponse: RefreshResponse = try await postRequest(endpoint: "/refresh", body: ["refresh_token": refreshToken])
            return (refreshResponse.access_token, refreshResponse.expires_in)
        } catch {
            print("Could not refresh access token with refresh token: \(error)")
            throw error
        }
    }

}
