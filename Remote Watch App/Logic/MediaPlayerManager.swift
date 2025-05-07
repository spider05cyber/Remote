//
//  MediaPlayerManager.swift
//  Remote
//
//  Created by Jayden Scarpa on 21/04/2025.
//

import SwiftUI
import Combine

class MediaPlayerManager: ObservableObject {
    @Published var mediaPlayers: [MediaPlayer] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    /// Fetches media player entities from the API
    /// - Parameters:
    ///   - apiURL: Base URL of the API
    ///   - apiKey: Authentication key for the API
    func fetchMediaPlayers(apiURL: String, apiKey: String) {
        guard !apiURL.isEmpty else {
            self.errorMessage = "API URL is not configured"
            return
        }
        
        guard !apiKey.isEmpty else {
            self.errorMessage = "API Key is not configured"
            return
        }
        
        guard let url = URL(string: "\(apiURL)/api/states") else {
            self.errorMessage = "Invalid API URL format"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: [Entity].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] entities in
                    self?.processEntities(entities)
                }
            )
            .store(in: &cancellables)
    }
    
    /// Processes the entities from the API response
    /// - Parameter entities: Array of entities returned from the API
    private func processEntities(_ entities: [Entity]) {
        // Filter to only include media players
        let mediaPlayerEntities = entities.filter { entity in
            entity.entity_id.hasPrefix("media_player")
        }
        
        // Transform Entity objects into MediaPlayer objects
        mediaPlayers = mediaPlayerEntities.map { entity in
            MediaPlayer(from: entity)
        }
        
        // If no media players were found, show a message
        if mediaPlayers.isEmpty {
            errorMessage = "No media players found"
        }
    }
    
    /// Handles errors from the API request
    /// - Parameter error: The error that occurred
    private func handleError(_ error: Error) {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                errorMessage = "No internet connection. Please check your network."
            case .timedOut:
                errorMessage = "Request timed out. Please try again."
            case .cannotFindHost:
                errorMessage = "Server not found. Please check the API URL."
            case .badServerResponse:
                errorMessage = "Invalid server response. Please check your API key."
            default:
                errorMessage = "Network error: \(urlError.localizedDescription)"
            }
        } else if let decodingError = error as? DecodingError {
            errorMessage = "Could not parse the server response. Format may have changed."
        } else {
            errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
    
    /// Refreshes the list of media players
    func refresh(apiURL: String, apiKey: String) {
        fetchMediaPlayers(apiURL: apiURL, apiKey: apiKey)
    }
    
    /// Cancels any ongoing API requests
    func cancelRequests() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        isLoading = false
    }
}

