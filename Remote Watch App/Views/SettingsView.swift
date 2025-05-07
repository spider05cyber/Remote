//
//  SettingsView.swift
//  Remote Watch App
//
//  Created by Jayden Scarpa on 21/04/2025.
//

import SwiftUI
struct SettingsView: View {
    @EnvironmentObject var apiConfiguration: APIConfigurationModel
    @EnvironmentObject var mediaManager: MediaPlayerManager
    @State private var isConnecting = false
    @State private var connectionStatus: String?
    @State private var showAlert = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            Section(header: Text("API Configuration")) {
                TextField("API URL", text: $apiConfiguration.apiURL)
                    .disableAutocorrection(true)
                
                TextField("API Key", text: $apiConfiguration.apiKey) // should be SecureField, but blocks pasting
            }
            
            Section {
                Button(action: connectToAPI) {
                    if isConnecting {
                        ProgressView()
                    } else {
                        Text("Load Media Players")
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(isConnecting)
                
                if let status = connectionStatus {
                    Text(status)
                        .foregroundColor(status.contains("Error") ? .red : .green)
                }
            }
        }
        .navigationTitle("Settings")
        .onDisappear {
            apiConfiguration.saveValues()
        }
        .alert("Success", isPresented: $showAlert) {
            Button("OK") { dismiss() }
        } message: {
            Text("Connection successful! Media players loaded.")
        }
    }
    
    private func connectToAPI() {
        isConnecting = true
        connectionStatus = "Connecting..."
        apiConfiguration.saveValues()
        
        mediaManager.fetchMediaPlayers(
            apiURL: apiConfiguration.apiURL,
            apiKey: apiConfiguration.apiKey
        )
        
        // Check for completion
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if !mediaManager.isLoading {
                timer.invalidate()
                isConnecting = false
                
                if let error = mediaManager.errorMessage {
                    connectionStatus = "Error: \(error)"
                } else {
                    connectionStatus = "Connected successfully"
                    showAlert = true
                }
            }
        }
    }
}
