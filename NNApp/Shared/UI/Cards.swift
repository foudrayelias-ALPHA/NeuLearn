import SwiftUI

struct HeroCard: View {
    let eyebrow: String
    let title: String
    let subtitle: String
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text(eyebrow.uppercased())
                    .font(AppTheme.captionFont)
                    .tracking(1.2)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(accent.opacity(0.12), in: Capsule())
                    .foregroundStyle(accent)

                Spacer()

                Circle()
                    .fill(accent.opacity(0.16))
                    .frame(width: 18, height: 18)
                    .overlay {
                        Circle()
                            .stroke(accent.opacity(0.35), lineWidth: 1)
                            .padding(4)
                    }
            }

            Text(title)
                .font(AppTheme.heroTitleFont)
                .foregroundStyle(AppTheme.ink)

            Text(subtitle)
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.mutedInk)
                .lineSpacing(3)

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [accent, accent.opacity(0.15)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 104, height: 4)
                .clipShape(Capsule())
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.surface, accent.opacity(0.10)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .stroke(accent.opacity(0.15), lineWidth: 1)

                Circle()
                    .fill(accent.opacity(0.08))
                    .frame(width: 180, height: 180)
                    .offset(x: 48, y: -56)
            }
        )
    }
}

struct SectionCard<Content: View>: View {
    let title: String
    let eyebrow: String?
    let content: Content

    init(title: String, eyebrow: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.eyebrow = eyebrow
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let eyebrow {
                Text(eyebrow.uppercased())
                    .font(AppTheme.captionFont)
                    .tracking(1.0)
                    .foregroundStyle(AppTheme.accent)
            }

            Text(title)
                .font(AppTheme.cardTitleFont)
                .foregroundStyle(AppTheme.ink)

            content
                .foregroundStyle(AppTheme.ink)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                .fill(AppTheme.surface.opacity(0.96))
        )
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                .stroke(AppTheme.ink.opacity(0.06), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 6)
    }
}

struct MetricPill: View {
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(AppTheme.captionFont)
                .tracking(1.0)
                .foregroundStyle(AppTheme.mutedInk)

            Text(value)
                .font(AppTheme.numberFont)
                .foregroundStyle(AppTheme.ink)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(tint.opacity(0.10))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(tint.opacity(0.18), lineWidth: 1)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        HeroCard(
            eyebrow: "Example",
            title: "A clear first impression",
            subtitle: "This app should feel authored and grounded, not synthetic.",
            accent: AppTheme.accent
        )

        SectionCard(title: "Section", eyebrow: "Reference") {
            Text("Reusable card styling for lessons and labs.")
        }
    }
    .padding()
    .background(AppBackground())
}
