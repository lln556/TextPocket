import Foundation
import AppKit
import ApplicationServices

final class PasteService {
    static let shared = PasteService()

    private init() {}

    /// 复制文本到剪贴板
    func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }

    /// 模拟 Cmd+V 粘贴
    func simulatePaste() {
        let source = CGEventSource(stateID: .hidSystemState)

        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true)
        keyDown?.flags = .maskCommand
        keyDown?.post(tap: .cghidEventTap)

        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
        keyUp?.post(tap: .cghidEventTap)
    }

    /// 复制并粘贴文本
    func copyAndPaste(_ text: String) {
        ClipboardMonitor.shared.isInternalCopy = true
        copyToClipboard(text)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.simulatePaste()
        }
    }
}
