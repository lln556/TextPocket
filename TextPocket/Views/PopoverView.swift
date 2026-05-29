import SwiftUI
import SwiftData

struct PopoverView: View {
    @ObservedObject var viewModel: ClipboardViewModel

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isAddingNew {
                AddRecordView(viewModel: viewModel)
            } else {
                SearchBar(text: $viewModel.searchText)
                    .padding(12)

                tabBar

                Divider()

                RecordListView(viewModel: viewModel)

                Divider()

                Button(action: { viewModel.isAddingNew = true }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("添加新记录")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(8)
                }
                .buttonStyle(.plain)
                .background(Color(NSColor.controlBackgroundColor))
            }
        }
        .frame(width: 300, height: 400)
        .onAppear {
            viewModel.fetchItems()
        }
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            tabButton(.recent, icon: "clock")
            tabButton(.frequent, icon: "star")
        }
        .padding(.horizontal, 12)
    }

    private func tabButton(_ tab: DisplayTab, icon: String) -> some View {
        Button(action: { viewModel.currentTab = tab }) {
            VStack(spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: icon)
                        .font(.caption)
                    Text(tab.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(viewModel.currentTab == tab ? .accentColor : .secondary)

                Rectangle()
                    .fill(viewModel.currentTab == tab ? Color.accentColor : Color.clear)
                    .frame(height: 2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }
}
