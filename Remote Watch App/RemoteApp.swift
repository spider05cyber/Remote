//
//  RemoteApp.swift
//  Remote Watch App
//
//  Created by Jayden Scarpa on 21/04/2025.
//

import SwiftUI

@main
struct Remote_Watch_AppApp: App {
    @StateObject private var apiConfiguration = APIConfigurationModel()
    @StateObject private var mediaPlayerManager = MediaPlayerManager()
    @StateObject private var remoteControlManager = RemoteControlManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(apiConfiguration)
                .environmentObject(mediaPlayerManager)
                .environmentObject(remoteControlManager)
        }
    }
}
