import SwiftUI

struct RecordRowView: View {
    let item: ClipboardItem
    let searchText: String
    let onSelect: () -> Void
    let onDelete: () -> Void
    let onPromote: (() -> Void)?
    let onEdit: () -> Void

    init(item: ClipboardItem, searchText: String = "", onSelect: @escaping () -> Void, onDelete: @escaping () -> Void, onPromote: (() -> Void)? = nil, onEdit: @escaping () -> Void) {
        self.item = item
        self.searchText = searchText
        self.onSelect = onSelect
        self.onDelete = onDelete
        self.onPromote = onPromote
        self.onEdit = onEdit
    }

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    if let title = item.title, !title.isEmpty {
                        highlightedText(title, font: .headline)
                            .lineLimit(1)
                    }

                    highlightedText(item.content, font: .subheadline, baseColor: .secondary)
                        .lineLimit(2)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button("编辑", action: onEdit)

            if let onPromote {
                Button("添加到常用", action: onPromote)
            }

            Divider()

            Button("删除", role: .destructive, action: onDelete)
        }
    }

    /// 模糊匹配字符高亮
    private func highlightedText(_ text: String, font: Font, baseColor: Color = .primary) -> Text {
        guard !searchText.isEmpty else {
            return Text(text).font(font).foregroundColor(baseColor)
        }

        let query = searchText.lowercased()
        let lower = text.lowercased()

        // 找出所有匹配位置
        var matched = Set<Int>()
        var qi = query.startIndex
        for (pos, char) in lower.enumerated() {
            if qi < query.endIndex && char == query[qi] {
                matched.insert(pos)
                qi = query.index(after: qi)
            }
        }

        // 按匹配状态分段渲染
        let chars = Array(text)
        var result = Text("")
        var runStart = 0
        var runMatched = matched.contains(0)

        for i in 1..<chars.count {
            let curMatched = matched.contains(i)
            if curMatched != runMatched {
                let segment = String(chars[runStart..<i])
                if runMatched {
                    result = result + Text(segment).font(font).bold().foregroundColor(.accentColor)
                } else {
                    result = result + Text(segment).font(font).foregroundColor(baseColor)
                }
                runStart = i
                runMatched = curMatched
            }
        }
        // 尾部
        let tail = String(chars[runStart...])
        if runMatched {
            result = result + Text(tail).font(font).bold().foregroundColor(.accentColor)
        } else {
            result = result + Text(tail).font(font).foregroundColor(baseColor)
        }

        return result
    }
}
