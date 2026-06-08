import Foundation
import AppKit
import Carbon

struct HotkeyConfiguration: Codable, Equatable {
    var keyCode: UInt32
    var carbonModifiers: UInt32
    var displayName: String

    static let defaultShortcut = HotkeyConfiguration(
        keyCode: UInt32(kVK_ANSI_V),
        carbonModifiers: UInt32(cmdKey | shiftKey),
        displayName: "⌘⇧V"
    )
}

final class HotkeyService: ObservableObject {
    static let shared = HotkeyService()

    @Published private(set) var configuration: HotkeyConfiguration
    @Published private(set) var registrationError: String?

    private var eventHotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?
    var onHotKeyPressed: (() -> Void)?

    private init() {
        configuration = Self.loadConfiguration()
    }

    /// 注册全局快捷键
    func register() {
        _ = register(configuration)
    }

    func updateShortcut(_ newConfiguration: HotkeyConfiguration) -> Bool {
        let previousConfiguration = configuration
        unregister()

        guard register(newConfiguration) else {
            let failedRegistrationError = registrationError
            _ = register(previousConfiguration)
            registrationError = failedRegistrationError
            return false
        }

        configuration = newConfiguration
        saveConfiguration(newConfiguration)
        return true
    }

    func restoreDefaultShortcut() {
        _ = updateShortcut(.defaultShortcut)
    }

    private func register(_ configuration: HotkeyConfiguration) -> Bool {
        unregister()
        registrationError = nil

        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        let selfPointer = Unmanaged.passUnretained(self).toOpaque()
        let handlerStatus = InstallEventHandler(
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
        guard handlerStatus == noErr else {
            registrationError = "无法监听快捷键事件。"
            return false
        }

        let hotKeyID = EventHotKeyID(signature: HotkeyService.hotKeySignature, id: HotkeyService.hotKeyID)
        let registerStatus = RegisterEventHotKey(
            configuration.keyCode,
            configuration.carbonModifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &eventHotKeyRef
        )
        guard registerStatus == noErr else {
            RemoveEventHandler(eventHandlerRef)
            eventHandlerRef = nil
            registrationError = "快捷键 \(configuration.displayName) 已被其他应用或系统占用。"
            return false
        }

        self.configuration = configuration
        return true
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

    private static let configurationKey = "HotkeyConfiguration"

    private static func loadConfiguration() -> HotkeyConfiguration {
        guard let data = UserDefaults.standard.data(forKey: configurationKey),
              let configuration = try? JSONDecoder().decode(HotkeyConfiguration.self, from: data) else {
            return .defaultShortcut
        }
        return configuration
    }

    private func saveConfiguration(_ configuration: HotkeyConfiguration) {
        guard let data = try? JSONEncoder().encode(configuration) else { return }
        UserDefaults.standard.set(data, forKey: Self.configurationKey)
    }
}
