import Foundation
import AppKit

final class ClipboardMonitor {
    static let shared = ClipboardMonitor()

    private var timer: Timer?
    private var lastChangeCount: Int = 0
    private let maxAutoRecordLength = 20_000
    /// 标记：是否正在执行应用自身的复制粘贴，避免重复记录
    var isInternalCopy = false

    private init() {}

    /// 开始监听剪贴板变化
    func start(interval: TimeInterval = 1.0, onChange: @escaping (String) -> Void) {
        lastChangeCount = NSPasteboard.general.changeCount

        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self else { return }
            let current = NSPasteboard.general.changeCount
            guard current != self.lastChangeCount else { return }
            self.lastChangeCount = current

            // 跳过应用自身触发的复制
            if self.isInternalCopy {
                self.isInternalCopy = false
                return
            }

            guard let text = NSPasteboard.general.string(forType: .string),
                  text.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 else {
                return
            }
            guard text.count <= self.maxAutoRecordLength else {
                return
            }

            onChange(text)
        }
    }

    /// 停止监听
    func stop() {
        timer?.invalidate()
        timer = nil
    }
}
