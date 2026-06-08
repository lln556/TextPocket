import Carbon
import SwiftUI

struct HotkeyRecorderView: NSViewRepresentable {
    var isRecording: Bool
    var onRecord: (HotkeyConfiguration) -> Void

    func makeNSView(context: Context) -> RecorderNSView {
        let view = RecorderNSView()
        view.onRecord = onRecord
        return view
    }

    func updateNSView(_ nsView: RecorderNSView, context: Context) {
        nsView.onRecord = onRecord
        if isRecording {
            DispatchQueue.main.async {
                nsView.window?.makeFirstResponder(nsView)
            }
        }
    }

    final class RecorderNSView: NSView {
        var onRecord: ((HotkeyConfiguration) -> Void)?

        override var acceptsFirstResponder: Bool { true }

        override func keyDown(with event: NSEvent) {
            guard let configuration = HotkeyConfiguration(event: event) else {
                NSSound.beep()
                return
            }
            onRecord?(configuration)
        }
    }
}

extension HotkeyConfiguration {
    init?(event: NSEvent) {
        let carbonModifiers = event.modifierFlags.carbonHotkeyModifiers
        guard carbonModifiers != 0 else { return nil }

        keyCode = UInt32(event.keyCode)
        self.carbonModifiers = carbonModifiers
        displayName = event.modifierFlags.shortcutDisplayPrefix + event.keyDisplayName
    }
}

private extension NSEvent.ModifierFlags {
    var carbonHotkeyModifiers: UInt32 {
        var result: UInt32 = 0
        if contains(.command) { result |= UInt32(cmdKey) }
        if contains(.shift) { result |= UInt32(shiftKey) }
        if contains(.option) { result |= UInt32(optionKey) }
        if contains(.control) { result |= UInt32(controlKey) }
        return result
    }

    var shortcutDisplayPrefix: String {
        var result = ""
        if contains(.control) { result += "⌃" }
        if contains(.option) { result += "⌥" }
        if contains(.shift) { result += "⇧" }
        if contains(.command) { result += "⌘" }
        return result
    }
}

private extension NSEvent {
    var keyDisplayName: String {
        switch Int(keyCode) {
        case kVK_Space: return "Space"
        case kVK_Delete: return "⌫"
        case kVK_Escape: return "Esc"
        case kVK_Tab: return "Tab"
        case kVK_Return: return "↩"
        case kVK_LeftArrow: return "←"
        case kVK_RightArrow: return "→"
        case kVK_UpArrow: return "↑"
        case kVK_DownArrow: return "↓"
        default:
            break
        }

        if let charactersIgnoringModifiers, !charactersIgnoringModifiers.isEmpty {
            return charactersIgnoringModifiers.uppercased()
        }

        return "#\(keyCode)"
    }
}
