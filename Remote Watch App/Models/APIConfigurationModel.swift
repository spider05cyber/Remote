//
//  APIConfigurationModel.swift
//  Remote
//
//  Created by Jayden Scarpa on 21/04/2025.
//

import SwiftUI
import Combine
import SwiftKeychainWrapper

class APIConfigurationModel: ObservableObject {
    @Published var apiKey: String
        @Published var apiURL: String
        
        init() {
            // First initialize properties with default values
            self.apiKey = ""
            self.apiURL = ""
            
            // After initialization is complete, load values
            self.loadStoredValues()
        }
        
        private func loadStoredValues() {
            // Now that self is fully initialized, we can safely load values
            self.apiKey = retrieveSecurely("apiKey") ?? ""
            self.apiURL = retrieveSecurely("apiURL") ?? ""
        }
        
        // Add this method to save values when needed
        func saveValues() {
            storeSecurely("apiKey", apiKey)
            storeSecurely("apiURL", apiURL)
        }
        
        private func storeSecurely(_ key: String, _ value: String) {
            let keychain = KeychainWrapper.standard
            keychain.set(value, forKey: key)
        }
        
        private func retrieveSecurely(_ key: String) -> String? {
            let keychain = KeychainWrapper.standard
            return keychain.string(forKey: key)
        }
}
