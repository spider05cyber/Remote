import SwiftUI
import UIKit

// Constants for crown rotation
private let ROTATION_AMOUNT: Double = 80   // Trigger every x units of rotation
private let MIN_NUDGE: Double = 10  // Ignore nudges smaller than this

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

struct PlayerControlView: View {
    let player: MediaPlayer
    @State private var showInstructions: Bool = false
    @State private var playHaptics: Bool = false
    @State private var playCrownHaptics: Bool = false
    @EnvironmentObject var apiConfiguration: APIConfigurationModel
    @EnvironmentObject var remoteControlManager: RemoteControlManager

    @State private var showPill: Bool = false
    @State private var lastCrownActivity: Date = Date()
    @State private var pillHideTask: Task<Void, Never>? = nil

    @State private var crownValue: Double = 0
    @State private var lastCrownValue: Double = 0
    @State private var crownAccumulator: Double = 0

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
                        if showPill {
                            CrownPillView(accumulator: crownAccumulator, maxAmount: ROTATION_AMOUNT)
                                .transition(.asymmetric(
                                    insertion: AnyTransition.move(edge: .trailing).combined(with: .opacity), // Slide in and fade in
                                    removal: AnyTransition.move(edge: .trailing).combined(with: .opacity)   // Slide out and fade out
                                ))
                        }
                    }
                    Spacer()
                }
            }
            .animation(.easeInOut(duration: 0.5), value: showPill) // Animate the pill view
            .animation(.easeInOut(duration: 2), value: showInstructions)
            .navigationTitle(player.name)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                showInstructions = true
                showPill = true // Show pill for affordance of volume control

                // Start a task to hide the pill after 3 seconds
                Task {
                    try? await Task.sleep(nanoseconds: 3_000_000_000) // Wait for 3 seconds
                    showPill = false // Hide the pill
                }
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
                isHapticFeedbackEnabled: true
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
        // Ignore tiny nudges
        guard abs(delta) > MIN_NUDGE else { return }

        // --- Pill logic start ---
        showPill = true
        lastCrownActivity = Date()
        startPillHideTimer()
        // --- Pill logic end ---

        crownAccumulator += delta

        // Only process one direction per event to avoid crossing zero and sending the opposite command
        if crownAccumulator >= ROTATION_AMOUNT {
            let steps = Int(crownAccumulator / ROTATION_AMOUNT)
            for _ in 0..<steps {
                playCrownHaptics.toggle()
                sendVolumeCommand("up")
            }
            crownAccumulator -= Double(steps) * ROTATION_AMOUNT
        } else if crownAccumulator <= -ROTATION_AMOUNT {
            let steps = Int(abs(crownAccumulator) / ROTATION_AMOUNT)
            for _ in 0..<steps {
                playCrownHaptics.toggle()
                sendVolumeCommand("down")
            }
            crownAccumulator += Double(steps) * ROTATION_AMOUNT
        }

        lastCrownValue = newValue
    }

    private func startPillHideTimer() {
        // Cancel previous timer if any
        pillHideTask?.cancel()
        pillHideTask = Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
            // Only hide if no new activity
            if Date().timeIntervalSince(lastCrownActivity) >= 3 {
                await MainActor.run {
                    showPill = false
                    crownAccumulator = 0
                }
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
            mediaPlayerId: player.volumeEntityId, // using volume ID for customisability
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
