import SwiftUI

/// A segmented control with a sliding accent pill.
struct PillSegmentedControl<Option: Hashable>: View {
    let options: [Option]
    @Binding var selection: Option
    let title: (Option) -> String

    @Namespace private var namespace

    var body: some View {
        HStack(spacing: Spacing.xxs) {
            ForEach(options, id: \.self) { option in
                segment(for: option)
            }
        }
        .padding(Spacing.xxs)
        .background(Theme.surface, in: Capsule())
    }

    private func segment(for option: Option) -> some View {
        let isSelected = option == selection
        return Button {
            withAnimation(.snappy(duration: 0.25)) { selection = option }
        } label: {
            Text(title(option))
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .foregroundStyle(isSelected ? Color.white : Theme.textSecondary)
                .frame(maxWidth: .infinity, minHeight: 40)
                .background {
                    if isSelected {
                        Capsule()
                            .fill(Theme.accent)
                            .matchedGeometryEffect(id: "selection", in: namespace)
                    }
                }
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    @Previewable @State var status = ListingStatus.active
    PillSegmentedControl(options: ListingStatus.allCases, selection: $status) { $0.title }
        .padding()
        .background(Theme.background)
}
