import SwiftUI

/// A playful collage of category tiles that fades into the background.
struct WelcomeHero: View {
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            ZStack {
                tile(.electronics)
                    .frame(width: width * 0.46, height: height * 0.56)
                    .rotationEffect(.degrees(-9))
                    .offset(x: -width * 0.22, y: -height * 0.12)
                tile(.fashion)
                    .frame(width: width * 0.44, height: height * 0.52)
                    .rotationEffect(.degrees(8))
                    .offset(x: width * 0.22, y: -height * 0.08)
                tile(.home)
                    .frame(width: width * 0.5, height: height * 0.5)
                    .rotationEffect(.degrees(-2))
                    .offset(y: height * 0.2)
            }
            .frame(width: width, height: height)
        }
        .background(
            LinearGradient(colors: [Theme.accentSoft, Theme.background], startPoint: .top, endPoint: .bottom),
        )
        .overlay(alignment: .bottom) {
            LinearGradient(colors: [Theme.background.opacity(0), Theme.background], startPoint: .top, endPoint: .bottom)
                .frame(height: 120)
        }
        .accessibilityHidden(true)
    }

    private func tile(_ category: ListingCategory) -> some View {
        CategoryPlaceholder(category: category, symbolSize: 64)
            .clipShape(.rect(cornerRadius: 32))
            .overlay(RoundedRectangle(cornerRadius: 32).strokeBorder(.white, lineWidth: 4))
            .shadow(color: Color.black.opacity(0.1), radius: 18, y: 10)
    }
}

#Preview {
    WelcomeHero()
        .frame(height: 420)
}
