import Foundation
import AppKit
import Carbon

final class HotkeyService {
    static let shared = HotkeyService()

    private var eventHotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?
    var onHotKeyPressed: (() -> Void)?

    private init() {}

    /// 注册全局快捷键 Cmd+Shift+V
    func register() {
        unregister()

        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        let selfPointer = Unmanaged.passUnretained(self).toOpaque()
        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, event, userData in
                var hotKeyID = EventHotKeyID()
                GetEventParameter(
                    event,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotKeyID
                )

                guard hotKeyID.id == HotkeyService.hotKeyID,
                      let userData else {
                    return noErr
                }

                let service = Unmanaged<HotkeyService>.fromOpaque(userData).takeUnretainedValue()
                service.onHotKeyPressed?()
                return noErr
            },
            1,
            &eventType,
            selfPointer,
            &eventHandlerRef
        )

        let hotKeyID = EventHotKeyID(signature: HotkeyService.hotKeySignature, id: HotkeyService.hotKeyID)
        RegisterEventHotKey(
            UInt32(kVK_ANSI_V),
            UInt32(cmdKey | shiftKey),
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &eventHotKeyRef
        )
    }

    /// 注销全局快捷键
    func unregister() {
        if let eventHotKeyRef {
            UnregisterEventHotKey(eventHotKeyRef)
            self.eventHotKeyRef = nil
        }

        if let eventHandlerRef {
            RemoveEventHandler(eventHandlerRef)
            self.eventHandlerRef = nil
        }
    }

    private static let hotKeyID: UInt32 = 1
    private static let hotKeySignature: OSType = {
        let scalars = Array("TXTP".unicodeScalars)
        return scalars.reduce(0) { ($0 << 8) + OSType($1.value) }
    }()
}
