import SwiftUI

struct SettingsView: View {
    @ObservedObject private var launchAtLoginService = LaunchAtLoginService.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
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
        }
        .padding(20)
        .frame(width: 360, alignment: .leading)
        .onAppear {
            launchAtLoginService.refresh()
        }
    }
}
