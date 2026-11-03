import SwiftUI

struct ProfileInfoRow: View {
    let systemImage: String
    let title: LocalizedStringKey
    let value: String

    var body: some View {
        HStack(spacing: Spacing.s) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.accentText)
                .frame(width: 32, height: 32)
                .background(Theme.accentSoft, in: Circle())
            Text(title)
                .foregroundStyle(Theme.ink)
            Spacer(minLength: Spacing.s)
            Text(value)
                .foregroundStyle(Theme.textSecondary)
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .font(.subheadline)
        .padding(.horizontal, Spacing.m)
        .frame(minHeight: 56)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ProfileInfoRow(systemImage: "phone", title: "Phone", value: "+971 50 987 6543")
        .background(Theme.surface)
        .padding()
}
