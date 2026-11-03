import SwiftUI

struct TabBarItem<Tab: Hashable>: Identifiable {
    let tab: Tab
    let title: LocalizedStringKey
    let systemImage: String

    var id: Tab { tab }
}
