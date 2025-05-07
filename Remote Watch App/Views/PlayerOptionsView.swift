import SwiftUI

struct PlayerOptionsView: View {
    @State var player: MediaPlayer

    @State private var volumeEntityId: String
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage: String = ""
    @State private var playHaptics: Bool
    @State private var brightnessValue: Double = 50
    @State private var brightnessEntityId: String = ""
    @FocusState private var sliderIsFocused: Bool

    @EnvironmentObject var apiConfiguration: APIConfigurationModel
    @EnvironmentObject var remoteControlManager: RemoteControlManager

    var body: some View {
        Form {
            Section(header: Text("Power Options")) {
                HStack {
                    Button(action: {
                        sendPowerOffCommand()
                        playHaptics.toggle()
                    }) {
                        HStack {
                            Image(systemName: "power")
                                .foregroundStyle(.red)
                            Text("Power Off")
                                .foregroundStyle(.red)
                        }
                    }
                }
            }

            Section(header: Text("Brightness Options")) {
                VStack {
                    Slider(
                        value: $brightnessValue,
                        in: 0...100,
                        step: 1,
                        onEditingChanged: { editing in
                            sliderIsFocused = editing
                        }
                    )
                    .focused($sliderIsFocused)
                    .digitalCrownRotation(
                        $brightnessValue,
                        from: 0,
                        through: 100,
                        by: 1,
                        sensitivity: .high,
                        isContinuous: false,
                        isHapticFeedbackEnabled: true
                    )
                    .disabled(brightnessEntityId.isEmpty)

                    Text("\(Int(brightnessValue))")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Button("Send Command") {
                        sliderIsFocused = false
                        sendBrightnessCommand()
                        playHaptics.toggle()
                    }
                    .buttonStyle(.borderless)
                    .padding(.top, 10)
                    .disabled(brightnessEntityId.isEmpty)
                }

                TextField("Brightness Entity ID", text: $brightnessEntityId)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
                    .font(.caption)
                    .padding(.top, 4)

                Button("Save Brightness Settings") {
                    saveBrightnessSettings()
                }
                .padding(.top, 2)
            }

            Section(header: Text("Sound Control")) {
                TextField("Sound Player Entity ID", text: $volumeEntityId)
                    .disableAutocorrection(true)

                Button("Save Sound Settings") {
                    saveSoundSettings()
                }
            }
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: playHaptics)
        .navigationTitle("Options")
        .alert("Success", isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Saved successfully.")
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            loadBrightnessEntityId()
            fetchBrightness()
        }
    }

    init(player: MediaPlayer) {
        _player = State(initialValue: player)
        _volumeEntityId = State(initialValue: player.volumeEntityId)
        _playHaptics = State(initialValue: false)
    }

    private func saveSoundSettings() {
        player.volumeEntityId = volumeEntityId
        showSuccessAlert = true
    }

    private func saveBrightnessSettings() {
        player.brightnessEntityId = brightnessEntityId
        showSuccessAlert = true
        fetchBrightness()
    }

    private func loadBrightnessEntityId() {
        brightnessEntityId = player.brightnessEntityId
    }

    private func sendPowerOffCommand() {
        remoteControlManager.sendPowerOffCommand(
            mediaPlayerId: player.entityId,
            apiURL: apiConfiguration.apiURL,
            apiKey: apiConfiguration.apiKey
        )
    }

    private func fetchBrightness() {
        guard !brightnessEntityId.isEmpty else { return }
        remoteControlManager.fetchBrightness(
            entityId: brightnessEntityId,
            apiURL: apiConfiguration.apiURL,
            apiKey: apiConfiguration.apiKey
        ) { value in
            if let value = value {
                brightnessValue = Double(value)
            } else {
                errorMessage = remoteControlManager.errorMessage ?? "Failed to fetch brightness"
                showErrorAlert = true
            }
        }
    }

    private func sendBrightnessCommand() {
        guard !brightnessEntityId.isEmpty else { return }
        remoteControlManager.sendBrightnessCommand(
            entityId: brightnessEntityId,
            brightnessPct: Int(brightnessValue),
            apiURL: apiConfiguration.apiURL,
            apiKey: apiConfiguration.apiKey
        ) { success in
            if success {
                // brevity
            } else {
                errorMessage = remoteControlManager.errorMessage ?? "Failed to send brightness command"
                showErrorAlert = true
            }
        }
    }
}
