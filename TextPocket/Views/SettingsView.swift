import SwiftUI

struct SettingsView: View {
    @ObservedObject private var launchAtLoginService = LaunchAtLoginService.shared
    @ObservedObject private var hotkeyService = HotkeyService.shared
    @State private var isRecordingHotkey = false
    @State private var hotkeyMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Toggle(
                "开机自动启动",
                isOn: Binding(
                    get: { launchAtLoginService.isEnabled },
                    set: { launchAtLoginService.setEnabled($0) }
                )
            )
            .toggleStyle(.switch)

            Text("开启后，TextPocket 会在你登录 Mac 时自动运行。")
                .font(.caption)
                .foregroundColor(.secondary)

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("全局快捷键")
                    Spacer()
                    Text(hotkeyService.configuration.displayName)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.secondary)
                }

                HStack(spacing: 8) {
                    Button(isRecordingHotkey ? "按下新的快捷键..." : "更改快捷键") {
                        hotkeyMessage = nil
                        isRecordingHotkey = true
                    }

                    Button("恢复默认") {
                        hotkeyMessage = nil
                        hotkeyService.restoreDefaultShortcut()
                    }
                }

                if let message = hotkeyMessage {
                    Text(message)
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("录制时请按下包含 Command、Option、Control 或 Shift 的组合键。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            HotkeyRecorderView(isRecording: isRecordingHotkey) { configuration in
                isRecordingHotkey = false
                if hotkeyService.updateShortcut(configuration) {
                    hotkeyMessage = "快捷键已更新为 \(configuration.displayName)。"
                    clearHotkeyMessageAfterDelay()
                } else {
                    hotkeyMessage = hotkeyService.registrationError
                    clearHotkeyMessageAfterDelay()
                }
            }
            .frame(width: 0, height: 0)
        }
        .padding(20)
        .frame(width: 420, alignment: .leading)
        .onAppear {
            launchAtLoginService.refresh()
            hotkeyMessage = nil
        }
    }

    private func clearHotkeyMessageAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            hotkeyMessage = nil
        }
    }
}
