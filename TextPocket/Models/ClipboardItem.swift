import Foundation
import SwiftData

@Model
final class ClipboardItem {
    var id: UUID
    var title: String?
    var content: String
    var createdAt: Date
    var lastUsedAt: Date
    var useCount: Int

    init(title: String? = nil, content: String) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.lastUsedAt = Date()
        self.useCount = 0
    }
}
