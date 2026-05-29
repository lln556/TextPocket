import SwiftUI
import SwiftData

@main
struct TextPocketApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
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

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 检查辅助功能权限
        _ = AccessibilityService.shared.checkAccessibility()

        // 设置 SwiftData 容器
        let modelContainer = try! ModelContainer(for: ClipboardItem.self)
        viewModel.setup(modelContext: modelContainer.mainContext)

        // 设置 Popover 内容
        popover.contentViewController = NSHostingController(
            rootView: PopoverView(viewModel: viewModel)
                .modelContainer(modelContainer)
        )

        // 触发 statusItem 初始化
        _ = statusItem

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

    @objc func quit() {
        ClipboardMonitor.shared.stop()
        HotkeyService.shared.unregister()
        NSApplication.shared.terminate(nil)
    }
}
