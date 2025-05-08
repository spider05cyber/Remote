import SwiftUI
import UIKit


struct PlayerInstructionsView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "chevron.up")
                .foregroundColor(.gray)
            HStack {
                Image(systemName: "chevron.left")
                    .foregroundColor(.gray)
                Text("SWIPE TO\nNAVIGATE")
                    .multilineTextAlignment(.center)
                    .font(.caption)
                    .foregroundColor(.gray)
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            Image(systemName: "chevron.down")
                .foregroundColor(.gray)
        }
    }
}
private let MIN_NUDGE: Double = 50  // Ignore nudges smaller than this

struct PlayerControlView: View {
    let player: MediaPlayer
    @State private var showInstructions: Bool = false
    @State private var playHaptics: Bool = false
    @State private var playCrownHaptics: Bool = false
    @EnvironmentObject var apiConfiguration: APIConfigurationModel
    @EnvironmentObject var remoteControlManager: RemoteControlManager

    @State private var crownValue: Double = 0
    @State private var lastCrownValue: Double = 0
    @State private var showVolumeIndicator: Bool = false
    @State private var volumeDirection: String = "" // "up" or "down"
    @State private var indicatorHideTask: Task<Void, Never>? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                if showInstructions {
                    PlayerInstructionsView()
                }
                
                VStack {
                    HStack {
                        Spacer()
                        if showVolumeIndicator {
                            VolumeIndicatorView(direction: volumeDirection)
                                .transition(.opacity)
                        }
                    }
                    Spacer()
                }
            }
            .animation(.easeInOut(duration: 0.3), value: showVolumeIndicator)
            .animation(.easeInOut(duration: 2), value: showInstructions)
            .navigationTitle(player.name)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                showInstructions = true
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: PlayerOptionsView(player: player)) {
                        Image(systemName: "ellipsis")
                    }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    Button {
                        playHaptics.toggle()
                        sendPlayPauseCommand()
                    } label: {
                        Image(systemName: "playpause.fill")
                    }
                    Button {
                        playHaptics.toggle()
                        sendRemoteKeyCommand("back")
                    } label: {
                        Image(systemName: "chevron.backward")
                    }
                    .controlSize(.large)
                    Button {
                        playHaptics.toggle()
                        sendRemoteKeyCommand("information")
                    } label: {
                        Image(systemName: "tv")
                            .symbolRenderingMode(.monochrome)
                    }
                }
            }
            .sensoryFeedback(.impact(weight: .medium), trigger: playHaptics)
            .sensoryFeedback(.impact(weight: .heavy, intensity: 10.0), trigger: playCrownHaptics)
            .onTapGesture {
                showInstructions = false
                playHaptics.toggle()
                sendRemoteKeyCommand("select")
            }
            .focusable(true)
            .digitalCrownRotation(
                $crownValue,
                from: -1000,
                through: 1000,
                sensitivity: .high,
                isContinuous: true,
                isHapticFeedbackEnabled: false
            )
            .onChange(of: crownValue) { oldValue, newValue in
                handleCrownRotation(newValue: newValue)
            }
            .gesture(
                DragGesture(minimumDistance: 20)
                    .onEnded { gesture in
                        showInstructions = false
                        let horizontalAmount = gesture.translation.width
                        let verticalAmount = gesture.translation.height
                        if abs(horizontalAmount) > abs(verticalAmount) {
                            if horizontalAmount < 0 {
                                sendRemoteKeyCommand("arrow_left")
                            } else {
                                sendRemoteKeyCommand("arrow_right")
                            }
                        } else {
                            if verticalAmount < 0 {
                                sendRemoteKeyCommand("arrow_up")
                            } else {
                                sendRemoteKeyCommand("arrow_down")
                            }
                        }
                    }
            )
        }
    }

    // MARK: - Helper Functions

    private func handleCrownRotation(newValue: Double) {
        let delta = newValue - lastCrownValue
        guard abs(delta) > MIN_NUDGE else { return }

        if delta > 0 {
            playCrownHaptics.toggle()
            sendVolumeCommand("up")
            showVolumeIndicator(direction: "up")
        } else if delta < 0 {
            playCrownHaptics.toggle()
            sendVolumeCommand("down")
            showVolumeIndicator(direction: "down")
        }

        lastCrownValue = newValue
    }

    private func showVolumeIndicator(direction: String) {
        volumeDirection = direction
        showVolumeIndicator = true
        // Cancel previous hide task if any
        indicatorHideTask?.cancel()
        indicatorHideTask = Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            await MainActor.run {
                showVolumeIndicator = false
            }
        }
    }

    private func sendRemoteKeyCommand(_ keyName: String) {
        remoteControlManager.sendRemoteCommand(
            keyName: keyName,
            mediaPlayerId: player.entityId,
            apiURL: apiConfiguration.apiURL,
            apiKey: apiConfiguration.apiKey
        )
    }
    
    private func sendVolumeCommand(_ direction: String) {
        remoteControlManager.sendVolumeCommand(
            direction: direction,
            mediaPlayerId: player.volumeEntityId,
            apiURL: apiConfiguration.apiURL,
            apiKey: apiConfiguration.apiKey
        )
    }

    private func sendPlayPauseCommand() {
        remoteControlManager.sendPlayPauseCommand(
            mediaPlayerId: player.entityId,
            apiURL: apiConfiguration.apiURL,
            apiKey: apiConfiguration.apiKey
        )
    }
}

struct VolumeIndicatorView: View {
    let direction: String
    var body: some View {
        HStack {
            Image(systemName: direction == "up" ? "speaker.wave.2.fill" : "speaker.wave.1.fill")
            Image(systemName: direction == "up" ? "arrow.up" : "arrow.down")
        }
        .padding(8)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .shadow(radius: 4)
        .foregroundColor(.white)
        .font(.title2)
        .padding(.trailing, 8)
    }
}
