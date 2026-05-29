import SwiftUI

struct AddRecordView: View {
    @ObservedObject var viewModel: ClipboardViewModel
    @FocusState private var isContentFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // 顶部导航栏
            HStack {
                Button(action: cancel) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.caption.bold())
                        Text("返回")
                            .font(.subheadline)
                    }
                }
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)

                Spacer()

                Text(viewModel.editingItem == nil ? "添加记录" : "编辑记录")
                    .font(.subheadline.bold())

                Spacer()

                Button("保存") {
                    viewModel.addItem()
                }
                .buttonStyle(.plain)
                .foregroundColor(viewModel.newContent.isEmpty ? .secondary : .accentColor)
                .disabled(viewModel.newContent.isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            // 表单
            VStack(spacing: 12) {
                // 标题
                TextField("标题（可选）", text: $viewModel.newTitle)
                    .textFieldStyle(.plain)
                    .padding(8)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(6)

                // 内容
                TextEditor(text: $viewModel.newContent)
                    .font(.body)
                    .scrollContentBackground(.hidden)
                    .padding(8)
                    .frame(maxHeight: .infinity)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(6)
                    .focused($isContentFocused)
            }
            .padding(16)
        }
        .onAppear {
            isContentFocused = true
        }
    }

    private func cancel() {
        viewModel.isAddingNew = false
        viewModel.newTitle = ""
        viewModel.newContent = ""
        viewModel.editingItem = nil
    }
}
