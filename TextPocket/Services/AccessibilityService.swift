import Foundation
import AppKit
import ApplicationServices

final class AccessibilityService {
    static let shared = AccessibilityService()

    private init() {}

    /// 检查辅助功能权限
    func checkAccessibility() -> Bool {
        AXIsProcessTrusted()
    }

    /// 请求辅助功能权限
    func requestAccessibility() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true]
        return AXIsProcessTrustedWithOptions(options as CFDictionary)
    }

    /// 打开系统设置的辅助功能页面
    func openAccessibilitySettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") else {
            return
        }
        NSWorkspace.shared.open(url)
    }
}
