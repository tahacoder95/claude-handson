import SwiftUI

/// "Hello, / Omar Haddad" with the user's avatar and an optional trailing accessory.
struct GreetingHeader<Accessory: View>: View {
    let greeting: LocalizedStringKey
    let name: String
    @ViewBuilder let accessory: Accessory

    var body: some View {
        HStack(spacing: Spacing.s) {
            HStack(spacing: Spacing.s) {
                AvatarView(name: name, size: 52)
                VStack(alignment: .leading, spacing: 2) {
                    Text(greeting)
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                    Text(name)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Theme.ink)
                        .lineLimit(1)
                }
            }
            .accessibilityElement(children: .combine)
            Spacer(minLength: 0)
            accessory
        }
    }
}

extension GreetingHeader where Accessory == EmptyView {
    init(greeting: LocalizedStringKey, name: String) {
        self.init(greeting: greeting, name: name) { EmptyView() }
    }
}

#Preview {
    VStack(spacing: Spacing.l) {
        GreetingHeader(greeting: "Hello,", name: "Omar Haddad")
        GreetingHeader(greeting: "Your shop,", name: "Omar Haddad") {
            ModeSwitchButton(currentMode: .selling) {}
        }
    }
    .padding()
}
