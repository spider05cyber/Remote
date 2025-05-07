//
//  ContentView.swift
//  Remote Watch App
//
//  Created by Jayden Scarpa on 21/04/2025.
//

import SwiftUI
struct ContentView: View {
    @EnvironmentObject var mediaManager: MediaPlayerManager
    @EnvironmentObject var apiConfiguration: APIConfigurationModel
    @State private var showingSettingsPrompt = false
    @State private var hasLoadedInitialData = false
    
    var body: some View {
        NavigationStack {
            Group {
                if mediaManager.isLoading {
                    loadingView
                } else if let error = mediaManager.errorMessage {
                    errorView(message: error)
                } else if mediaManager.mediaPlayers.isEmpty {
                    emptyStateView
                } else {
                    List {
                        ForEach(mediaManager.mediaPlayers) { player in
                            NavigationLink(destination: PlayerControlView(player: player)) {
                                MediaPlayerCard(player: player)
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .listStyle(.plain)
                    .padding(.horizontal, 0)
                }
            }
            .navigationTitle("Remote")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                    }
                }
            }
            .alert("Setup Required", isPresented: $showingSettingsPrompt) {
                Button("Go to Settings") { }
            } message: {
                Text("Please configure your API settings to view media players.")
            }
        }
        .onAppear {
            if !hasLoadedInitialData {
                checkAndLoadMediaPlayers()
                hasLoadedInitialData = true
            }
        }
    }
    
    // Helper views and functions
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
            Text("Loading...")
                .font(.caption)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack {
            Spacer()
            Image(systemName: "speaker.slash")
                .font(.system(size: 30))
            Text("No Players Found")
                .font(.caption)
                .padding(.top, 4)
            Text("Check settings and try again.")
                .font(.caption2)
                .padding(.horizontal)
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    private func errorView(message: String) -> some View {
        VStack {
            Spacer()
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 30))
                .foregroundColor(.orange)
            Text("Error")
                .font(.caption)
            Text(message)
                .font(.caption2)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    private func checkAndLoadMediaPlayers() {
            if !apiConfiguration.apiURL.isEmpty && !apiConfiguration.apiKey.isEmpty {
                mediaManager.fetchMediaPlayers(
                    apiURL: apiConfiguration.apiURL,
                    apiKey: apiConfiguration.apiKey
                )
            }
        }
}
