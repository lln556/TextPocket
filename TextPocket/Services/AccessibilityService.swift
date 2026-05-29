import Foundation
import ApplicationServices

final class AccessibilityService {
    static let shared = AccessibilityService()

    private init() {}

    /// 检查辅助功能权限
    func checkAccessibility() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true]
        return AXIsProcessTrustedWithOptions(options as CFDictionary)
    }

    /// 打开系统设置的辅助功能页面
    func openAccessibilitySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }
}
