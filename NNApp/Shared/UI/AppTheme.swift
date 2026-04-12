import SwiftUI

enum AppTheme {
    static let background = Color(red: 0.95, green: 0.92, blue: 0.85)
    static let backgroundTint = Color(red: 0.87, green: 0.84, blue: 0.76)
    static let surface = Color(red: 0.98, green: 0.97, blue: 0.93)
    static let surfaceStrong = Color(red: 0.93, green: 0.90, blue: 0.82)
    static let ink = Color(red: 0.15, green: 0.16, blue: 0.18)
    static let mutedInk = Color(red: 0.39, green: 0.38, blue: 0.36)
    static let accent = Color(red: 0.11, green: 0.34, blue: 0.53)
    static let accentWarm = Color(red: 0.80, green: 0.43, blue: 0.19)
    static let positive = Color(red: 0.16, green: 0.49, blue: 0.38)
    static let negative = Color(red: 0.65, green: 0.27, blue: 0.18)
    static let nodeInput = Color(red: 0.85, green: 0.60, blue: 0.28)
    static let nodeHidden = Color(red: 0.34, green: 0.48, blue: 0.65)
    static let nodeOutput = Color(red: 0.18, green: 0.45, blue: 0.39)

    static let screenPadding: CGFloat = 20
    static let cardRadius: CGFloat = 26

    static let heroTitleFont = Font.system(size: 34, weight: .bold, design: .serif)
    static let titleFont = Font.system(size: 28, weight: .bold, design: .serif)
    static let cardTitleFont = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let bodyFont = Font.system(size: 16, weight: .regular, design: .rounded)
    static let captionFont = Font.system(size: 12, weight: .semibold, design: .rounded)
    static let numberFont = Font.system(size: 20, weight: .semibold, design: .monospaced)
}

struct AppBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppTheme.background, AppTheme.surface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(AppTheme.accent.opacity(0.10))
                .frame(width: 260, height: 260)
                .blur(radius: 6)
                .offset(x: 150, y: -220)

            Circle()
                .fill(AppTheme.accentWarm.opacity(0.12))
                .frame(width: 240, height: 240)
                .blur(radius: 8)
                .offset(x: -140, y: 120)

            RoundedRectangle(cornerRadius: 48, style: .continuous)
                .fill(AppTheme.backgroundTint.opacity(0.25))
                .frame(width: 300, height: 220)
                .rotationEffect(.degrees(-12))
                .offset(x: 120, y: 280)
        }
        .ignoresSafeArea()
    }
}
