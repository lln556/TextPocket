import XCTest
@testable import TextPocket

@MainActor
final class ClipboardViewModelTests: XCTestCase {
    func testFrequentItemsContainOnlyManualItems() {
        let viewModel = ClipboardViewModel()

        let auto = ClipboardItem(content: "auto", source: .auto)
        auto.useCount = 10
        let manual = ClipboardItem(content: "manual", source: .manual)

        viewModel.items = [auto, manual]

        XCTAssertEqual(viewModel.frequentItems.map(\.content), ["manual"])
    }

    func testManualSourceMovesAutoItemIntoFrequentItems() {
        let viewModel = ClipboardViewModel()
        let item = ClipboardItem(content: "promote me", source: .auto)
        viewModel.items = [item]

        item.sourceRaw = ItemSource.manual.rawValue

        XCTAssertEqual(viewModel.frequentItems.map(\.content), ["promote me"])
    }
}
