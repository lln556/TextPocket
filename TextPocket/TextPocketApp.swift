import SwiftUI
import SwiftData

@main
struct TextPocketApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    lazy var popover: NSPopover = {
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 300, height: 400)
        popover.behavior = .transient
        return popover
    }()

    lazy var statusItem: NSStatusItem = {
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "TextPocket")
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.action = #selector(handleStatusItemClick)
            button.target = self
        }
        return statusItem
    }()

    lazy var viewModel: ClipboardViewModel = {
        return ClipboardViewModel()
    }()
    private var settingsWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 设置 SwiftData 容器
        let modelContainer = makeModelContainer()
        viewModel.setup(modelContext: modelContainer.mainContext)

        // 设置 Popover 内容
        popover.contentViewController = NSHostingController(
            rootView: PopoverView(viewModel: viewModel)
                .modelContainer(modelContainer)
        )

        // 触发 statusItem 初始化
        _ = statusItem
        _ = AccessibilityService.shared.requestAccessibility()

        // 注册全局快捷键
        let hotkeyService = HotkeyService.shared
        hotkeyService.onHotKeyPressed = { [weak self] in
            self?.togglePopover()
        }
        hotkeyService.register()

        // 启动剪贴板监听
        ClipboardMonitor.shared.start { [weak self] text in
            DispatchQueue.main.async {
                self?.viewModel.addFromClipboard(text)
            }
        }
    }

    private func makeModelContainer() -> ModelContainer {
        do {
            let schema = Schema([ClipboardItem.self])
            let storeURL = try textPocketStoreURL()
            let configuration = ModelConfiguration(schema: schema, url: storeURL)
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to initialize TextPocket SwiftData store: \(error)")
        }
    }

    private func textPocketStoreURL() throws -> URL {
        let appSupportURL = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let appDirectoryURL = appSupportURL.appendingPathComponent("TextPocket", isDirectory: true)
        try FileManager.default.createDirectory(at: appDirectoryURL, withIntermediateDirectories: true)
        return appDirectoryURL.appendingPathComponent("TextPocket.store")
    }

    @objc func handleStatusItemClick(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }
        if event.type == .rightMouseUp {
            showStatusMenu()
        } else {
            togglePopover()
        }
    }

    private func showStatusMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "偏好设置...", action: #selector(showSettings), keyEquivalent: ","))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "退出 TextPocket", action: #selector(quit), keyEquivalent: "q"))
        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }

    @objc func togglePopover() {
        if popover.isShown {
            popover.performClose(nil)
        } else {
            if let button = statusItem.button {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }

    @objc func showSettings() {
        NSApp.activate(ignoringOtherApps: true)
        if settingsWindow == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 460, height: 260),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            window.title = "TextPocket 偏好设置"
            window.contentViewController = NSHostingController(rootView: SettingsView())
            window.center()
            window.isReleasedWhenClosed = false
            settingsWindow = window
        }

        settingsWindow?.makeKeyAndOrderFront(nil)
    }

    @objc func quit() {
        ClipboardMonitor.shared.stop()
        HotkeyService.shared.unregister()
        NSApplication.shared.terminate(nil)
    }
}
