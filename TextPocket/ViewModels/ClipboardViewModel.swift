import Foundation
import SwiftData

/// 浮窗展示的 Tab
enum DisplayTab: String, CaseIterable {
    case recent = "最近"
    case frequent = "常用"
}

final class ClipboardViewModel: ObservableObject {
    @Published var items: [ClipboardItem] = []
    @Published var searchText: String = ""
    @Published var isAddingNew: Bool = false
    @Published var newTitle: String = ""
    @Published var newContent: String = ""
    @Published var currentTab: DisplayTab = .recent
    @Published var editingItem: ClipboardItem? = nil

    private var modelContext: ModelContext?

    /// 最近剪贴板（自动记录，按时间倒序，最多 50 条）
    var recentItems: [ClipboardItem] {
        let autoItems = items.filter { $0.source == .auto }
        if searchText.isEmpty {
            return Array(autoItems.sorted { $0.lastUsedAt > $1.lastUsedAt }.prefix(50))
        }
        return autoItems.filter { matchesSearch($0) }
            .sorted { $0.lastUsedAt > $1.lastUsedAt }
    }

    /// 常用文本（手动添加 + 使用次数 >= 3 的自动记录，按使用次数排序）
    var frequentItems: [ClipboardItem] {
        let frequent = items.filter {
            $0.source == .manual || $0.useCount >= 3
        }
        if searchText.isEmpty {
            return frequent.sorted { $0.useCount > $1.useCount }
        }
        return frequent.filter { matchesSearch($0) }
            .sorted { $0.useCount > $1.useCount }
    }

    /// 当前 Tab 对应的列表
    var displayedItems: [ClipboardItem] {
        currentTab == .recent ? recentItems : frequentItems
    }

    func setup(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchItems()
    }

    func fetchItems() {
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<ClipboardItem>(
            sortBy: [SortDescriptor(\.lastUsedAt, order: .reverse)]
        )
        items = (try? modelContext.fetch(descriptor)) ?? []
    }

    /// 手动添加或更新记录
    func addItem() {
        guard let modelContext, !newContent.isEmpty else { return }

        if let editing = editingItem {
            // 编辑模式：更新原记录
            editing.title = newTitle.isEmpty ? nil : newTitle
            editing.content = newContent
            editing.sourceRaw = ItemSource.manual.rawValue
            try? modelContext.save()
        } else {
            // 新增模式
            let item = ClipboardItem(
                title: newTitle.isEmpty ? nil : newTitle,
                content: newContent,
                source: .manual
            )
            modelContext.insert(item)
            try? modelContext.save()
        }

        newTitle = ""
        newContent = ""
        editingItem = nil
        isAddingNew = false
        fetchItems()
    }

    /// 将自动记录提升到常用
    func promoteToManual(_ item: ClipboardItem) {
        guard let modelContext else { return }
        item.sourceRaw = ItemSource.manual.rawValue
        try? modelContext.save()
        fetchItems()
    }

    /// 开始编辑记录
    func startEditing(_ item: ClipboardItem) {
        editingItem = item
        newTitle = item.title ?? ""
        newContent = item.content
        isAddingNew = true
    }

    /// 使用记录（粘贴）
    func useItem(_ item: ClipboardItem) {
        guard let modelContext else { return }

        item.lastUsedAt = Date()
        item.useCount += 1
        try? modelContext.save()

        PasteService.shared.copyAndPaste(item.content)
        fetchItems()
    }

    /// 删除记录
    func deleteItem(_ item: ClipboardItem) {
        guard let modelContext else { return }

        modelContext.delete(item)
        try? modelContext.save()
        fetchItems()
    }

    /// 从剪贴板自动记录（去重 + 限制最近 50 条）
    func addFromClipboard(_ text: String) {
        guard let modelContext else { return }

        // 去重：内容已存在则更新时间和次数
        if let existing = items.first(where: { $0.content == text }) {
            existing.lastUsedAt = Date()
            existing.useCount += 1
            try? modelContext.save()
            fetchItems()
            return
        }

        // 限制最近剪贴板数量
        let autoItems = items.filter { $0.source == .auto }
        if autoItems.count >= 50 {
            let oldest = autoItems.sorted { $0.createdAt < $1.createdAt }.first!
            modelContext.delete(oldest)
        }

        let item = ClipboardItem(content: text, source: .auto)
        item.useCount = 1
        modelContext.insert(item)
        try? modelContext.save()
        fetchItems()
    }

    // MARK: - Private

    /// 模糊匹配：搜索字符按顺序出现在目标中即可（非连续）
    private func matchesSearch(_ item: ClipboardItem) -> Bool {
        let query = searchText.lowercased()
        let title = (item.title ?? "").lowercased()
        let content = item.content.lowercased()
        return fuzzyMatch(query: query, in: title) || fuzzyMatch(query: query, in: content)
    }

    private func fuzzyMatch(query: String, in text: String) -> Bool {
        var qi = query.startIndex
        for char in text {
            if char == query[qi] {
                qi = query.index(after: qi)
                if qi == query.endIndex { return true }
            }
        }
        return false
    }
}
