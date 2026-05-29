import Foundation
import AppKit
import HotKey
import Carbon

final class HotkeyService {
    static let shared = HotkeyService()

    private var hotKey: HotKey?
    var onHotKeyPressed: (() -> Void)?

    private init() {}

    /// 注册全局快捷键 Cmd+Shift+V
    func register(key: Key = .v, modifiers: NSEvent.ModifierFlags = [.command, .shift]) {
        hotKey = HotKey(key: key, modifiers: modifiers)
        hotKey?.keyDownHandler = { [weak self] in
            self?.onHotKeyPressed?()
        }
    }

    /// 注销全局快捷键
    func unregister() {
        hotKey = nil
    }
}
