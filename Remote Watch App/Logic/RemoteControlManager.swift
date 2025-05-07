//
//  RemoteControlManager.swift
//  Remote
//
//  Created by Jayden Scarpa on 22/04/2025.
//

import Foundation
import Combine

class RemoteControlManager: ObservableObject {
    @Published var isProcessing = false
    @Published var errorMessage: String? = nil
    private var cancellables = Set<AnyCancellable>()
    
    /// Sends a remote control command to a media player
    /// - Parameters:
    ///   - keyName: The remote control key that was pressed
    ///   - mediaPlayerId: The entity ID of the target media player
    ///   - apiURL: Base URL of the API
    ///   - apiKey: Authentication key for the API
    ///   - completion: Optional closure called when the command completes
    func sendRemoteCommand(keyName: String, mediaPlayerId: String, apiURL: String, apiKey: String, completion: ((Bool) -> Void)? = nil) {
        guard !apiURL.isEmpty else {
            self.errorMessage = "API URL is not configured"
            completion?(false)
            return
        }
        
        guard !apiKey.isEmpty else {
            self.errorMessage = "API Key is not configured"
            completion?(false)
            return
        }
        
        guard let url = URL(string: "\(apiURL)/api/events/homekit_tv_remote_key_pressed") else {
            self.errorMessage = "Invalid API URL format"
            completion?(false)
            return
        }
        
        isProcessing = true
        errorMessage = nil
        
        let payload: [String: String] = [
            "key_name": keyName,
            "entity_id": mediaPlayerId
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONEncoder().encode(payload)
        } catch {
            self.errorMessage = "Error encoding command payload"
            self.isProcessing = false
            completion?(false)
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.response as? HTTPURLResponse }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isProcessing = false
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self?.handleError(error)
//                        completion?(false)
                    }
                },
                receiveValue: { [weak self] response in
                    if let httpResponse = response, httpResponse.statusCode == 200 {
                        completion?(true)
                    } else {
                        self?.errorMessage = "Server returned error: \(response?.statusCode ?? 0)"
                        completion?(false)
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    /// Sends a play/pause command to the media player
    /// - Parameters:
    ///   - mediaPlayerId: The entity ID of the target media player
    ///   - apiURL: Base URL of the API
    ///   - apiKey: Authentication key for the API
    ///   - completion: Optional closure called when the command completes
    func sendPlayPauseCommand(mediaPlayerId: String, apiURL: String, apiKey: String, completion: ((Bool) -> Void)? = nil) {
        guard !apiURL.isEmpty else {
            self.errorMessage = "API URL is not configured"
            completion?(false)
            return
        }
        
        guard !apiKey.isEmpty else {
            self.errorMessage = "API Key is not configured"
            completion?(false)
            return
        }
        
        guard let url = URL(string: "\(apiURL)/api/services/media_player/media_play_pause") else {
            self.errorMessage = "Invalid API URL format"
            completion?(false)
            return
        }
        
        isProcessing = true
        errorMessage = nil
        
        let payload: [String: String] = [
            "entity_id": mediaPlayerId
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONEncoder().encode(payload)
        } catch {
            self.errorMessage = "Error encoding command payload"
            self.isProcessing = false
            completion?(false)
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.response as? HTTPURLResponse }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isProcessing = false
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] response in
                    if let httpResponse = response, httpResponse.statusCode == 200 {
                        completion?(true)
                    } else {
                        self?.errorMessage = "Server returned error: \(response?.statusCode ?? 0)"
                        completion?(false)
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func sendPowerOffCommand(mediaPlayerId: String, apiURL: String, apiKey: String, completion: ((Bool) -> Void)? = nil) {
        guard !apiURL.isEmpty else {
            self.errorMessage = "API URL is not configured"
            completion?(false)
            return
        }
        
        guard !apiKey.isEmpty else {
            self.errorMessage = "API Key is not configured"
            completion?(false)
            return
        }
        
        guard let url = URL(string: "\(apiURL)/api/services/media_player/turn_off") else {
            self.errorMessage = "Invalid API URL format"
            completion?(false)
            return
        }
        
        isProcessing = true
        errorMessage = nil
        
        let payload: [String: String] = [
            "entity_id": mediaPlayerId
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONEncoder().encode(payload)
        } catch {
            self.errorMessage = "Error encoding command payload"
            self.isProcessing = false
            completion?(false)
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.response as? HTTPURLResponse }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isProcessing = false
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] response in
                    if let httpResponse = response, httpResponse.statusCode == 200 {
                        completion?(true)
                    } else {
                        self?.errorMessage = "Server returned error: \(response?.statusCode ?? 0)"
                        completion?(false)
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    /// Fetches the state of a given entity as an integer
    /// - Parameters:
    ///   - entityId: The entity ID to fetch state for
    ///   - apiURL: Base URL of the API
    ///   - apiKey: Authentication key for the API
    ///   - completion: Closure called with the integer state or nil if error
    func fetchBrightness(entityId: String, apiURL: String, apiKey: String, completion: @escaping (Int?) -> Void) {
        guard !apiURL.isEmpty else {
            self.errorMessage = "API URL is not configured"
            completion(nil)
            return
        }
        
        guard !apiKey.isEmpty else {
            self.errorMessage = "API Key is not configured"
            completion(nil)
            return
        }
        
        guard let url = URL(string: "\(apiURL)/api/states/\(entityId)") else {
            self.errorMessage = "Invalid API URL format"
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.handleError(error)
                    completion(nil)
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "No data received"
                    completion(nil)
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let stateString = json["state"] as? String,
                       let stateDouble = Double(stateString) {
                        completion(Int(stateDouble))
                    } else {
                        self?.errorMessage = "Invalid JSON structure"
                        completion(nil)
                    }
                } catch {
                    self?.errorMessage = "Failed to parse JSON: \(error.localizedDescription)"
                    completion(nil)
                }
            }
        }.resume()
    }
    
    /// Sends a brightness command to an input_number entity
    /// - Parameters:
    ///   - entityId: The entity ID of the input_number
    ///   - brightnessPct: The brightness percentage to set (0-100)
    ///   - apiURL: Base URL of the API
    ///   - apiKey: Authentication key for the API
    ///   - completion: Optional closure called when the command completes
    func sendBrightnessCommand(entityId: String, brightnessPct: Int, apiURL: String, apiKey: String, completion: ((Bool) -> Void)? = nil) {
        guard !apiURL.isEmpty else {
            self.errorMessage = "API URL is not configured"
            completion?(false)
            return
        }
        
        guard !apiKey.isEmpty else {
            self.errorMessage = "API Key is not configured"
            completion?(false)
            return
        }
        
        guard let url = URL(string: "\(apiURL)/api/services/input_number/set_value") else {
            self.errorMessage = "Invalid API URL format"
            completion?(false)
            return
        }
        
        isProcessing = true
        errorMessage = nil
        
        let payload: [String: Any] = [
            "entity_id": entityId,
            "value": brightnessPct
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            self.errorMessage = "Error encoding command payload"
            self.isProcessing = false
            completion?(false)
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.response as? HTTPURLResponse }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completionResult in
                    self?.isProcessing = false
                    switch completionResult {
                    case .finished:
                        break
                    case .failure(let error):
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] response in
                    if let httpResponse = response, httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                        completion?(true)
                    } else {
                        self?.errorMessage = "Server returned error: \(response?.statusCode ?? 0)"
                        completion?(false)
                    }
                }
            )
            .store(in: &cancellables)
    }


    
    /// Sends a volume control command (up or down) to the media player
    /// - Parameters:
    ///   - direction: The direction of the volume adjustment ("up" or "down")
    ///   - mediaPlayerId: The entity ID of the target media player
    ///   - apiURL: Base URL of the API
    ///   - apiKey: Authentication key for the API
    ///   - completion: Optional closure called when the command completes
    func sendVolumeCommand(direction: String, mediaPlayerId: String, apiURL: String, apiKey: String, completion: ((Bool) -> Void)? = nil) {
        guard !apiURL.isEmpty else {
            self.errorMessage = "API URL is not configured"
            completion?(false)
            return
        }
        
        guard !apiKey.isEmpty else {
            self.errorMessage = "API Key is not configured"
            completion?(false)
            return
        }
        
        // Determine the URL path based on the direction
        let endpoint: String
        switch direction.lowercased() {
        case "up":
            endpoint = "volume_up"
        case "down":
            endpoint = "volume_down"
        default:
            self.errorMessage = "Invalid direction. Use 'up' or 'down'."
            completion?(false)
            return
        }
        
        guard let url = URL(string: "\(apiURL)/api/services/media_player/\(endpoint)") else {
            self.errorMessage = "Invalid API URL format"
            completion?(false)
            return
        }
        
        isProcessing = true
        errorMessage = nil
        
        let payload: [String: String] = [
            "entity_id": mediaPlayerId
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONEncoder().encode(payload)
        } catch {
            self.errorMessage = "Error encoding command payload"
            self.isProcessing = false
            completion?(false)
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.response as? HTTPURLResponse }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isProcessing = false
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] response in
                    if let httpResponse = response, httpResponse.statusCode == 200 {
                        completion?(true)
                    } else {
                        self?.errorMessage = "Server returned error: \(response?.statusCode ?? 0)"
                        completion?(false)
                    }
                }
            )
            .store(in: &cancellables)
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
        } else {
            errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
    
    /// Cancels any ongoing API requests
    func cancelRequests() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        isProcessing = false
    }
}
