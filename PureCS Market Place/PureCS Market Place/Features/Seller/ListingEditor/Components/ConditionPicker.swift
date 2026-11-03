import SwiftUI

struct ConditionPicker: View {
    @Binding var selection: ItemCondition

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Condition")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.ink)
            PillSegmentedControl(options: ItemCondition.allCases, selection: $selection) { $0.title }
        }
    }
}

#Preview {
    @Previewable @State var condition = ItemCondition.good
    ConditionPicker(selection: $condition)
        .padding()
        .background(Theme.background)
}
