import Foundation
import SwiftData

/// 记录来源
enum ItemSource: String, Codable {
    case manual  // 手动添加
    case auto    // 剪贴板自动记录
}

@Model
final class ClipboardItem {
    var id: UUID
    var title: String?
    var content: String
    var createdAt: Date
    var lastUsedAt: Date
    var useCount: Int
    var sourceRaw: String = ItemSource.auto.rawValue

    var source: ItemSource {
        get { ItemSource(rawValue: sourceRaw) ?? .auto }
        set { sourceRaw = newValue.rawValue }
    }

    init(title: String? = nil, content: String, source: ItemSource = .manual) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.lastUsedAt = Date()
        self.useCount = 0
        self.sourceRaw = source.rawValue
    }
}
