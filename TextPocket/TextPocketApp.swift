import SwiftUI

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
            button.action = #selector(togglePopover)
            button.target = self
        }
        return statusItem
    }()

    lazy var viewModel: ClipboardViewModel = {
        return ClipboardViewModel()
    }()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 设置 Popover 内容
        popover.contentViewController = NSHostingController(
            rootView: PopoverView(viewModel: viewModel)
        )

        // 触发 statusItem 初始化
        _ = statusItem
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
}
