import SwiftUI

struct RecordListView: View {
    @ObservedObject var viewModel: ClipboardViewModel

    var body: some View {
        ScrollView {
            if viewModel.displayedItems.isEmpty {
                emptyState
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.displayedItems) { item in
                        RecordRowView(
                            item: item,
                            searchText: viewModel.searchText,
                            onSelect: { viewModel.useItem(item) },
                            onDelete: { viewModel.deleteItem(item) },
                            onPromote: item.source == .auto ? { viewModel.promoteToManual(item) } : nil,
                            onEdit: { viewModel.startEditing(item) }
                        )
                    }
                }
                .padding(8)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: viewModel.currentTab == .recent ? "clock" : "star")
                .font(.title2)
                .foregroundColor(.secondary)

            Text(viewModel.currentTab == .recent
                ? "复制文本后将自动出现在这里"
                : "手动添加的记录会显示在这里")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
