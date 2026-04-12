import SwiftUI

struct CreditsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView {
                    VStack(spacing: 32) {
                        VStack(spacing: 8) {
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 40))
                                .foregroundStyle(AppTheme.accent)
                            Text("Neural Networks")
                                .font(AppTheme.titleFont)
                                .foregroundStyle(AppTheme.ink)
                        }
                        .padding(.top, 20)

                        VStack(spacing: 20) {
                            creditRow(
                                label: "Author",
                                value: "Elias Foudray"
                            )

                            Divider()
                                .overlay(AppTheme.mutedInk.opacity(0.15))

                            creditRow(
                                label: "Advisor",
                                value: "Margaret Santini"
                            )

                            Divider()
                                .overlay(AppTheme.mutedInk.opacity(0.15))

                            creditRow(
                                label: "Advisor",
                                value: "Everett Foudray"
                            )

                            Divider()
                                .overlay(AppTheme.mutedInk.opacity(0.15))

                            creditRow(
                                label: "Beta Tester",
                                value: "Thomas Gaffey"
                            )

                            Divider()
                                .overlay(AppTheme.mutedInk.opacity(0.15))

                            VStack(alignment: .leading, spacing: 6) {
                                Text("App Icon")
                                    .font(AppTheme.captionFont)
                                    .foregroundStyle(AppTheme.mutedInk)
                                Text("Designed by rawpixel.com / Freepik")
                                    .font(AppTheme.bodyFont)
                                    .foregroundStyle(AppTheme.ink)
                                Link("freepik.com", destination: URL(string: "https://www.freepik.com")!)
                                    .font(AppTheme.captionFont)
                                    .foregroundStyle(AppTheme.accent)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            Divider()
                                .overlay(AppTheme.mutedInk.opacity(0.15))

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Privacy Policy")
                                    .font(AppTheme.captionFont)
                                    .foregroundStyle(AppTheme.mutedInk)
                                Link(
                                    "View Privacy Policy",
                                    destination: URL(string: "https://docs.google.com/document/d/1OVDgKAzpzaayKtAdbmRI6O8w7oyPpoMd/edit?usp=sharing&ouid=100248676815377500761&rtpof=true&sd=true")!
                                )
                                .font(AppTheme.bodyFont)
                                .foregroundStyle(AppTheme.accent)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                                .fill(AppTheme.surface.opacity(0.96))
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                                .stroke(AppTheme.mutedInk.opacity(0.08), lineWidth: 1)
                        }
                    }
                    .padding(AppTheme.screenPadding)
                }
            }
            .navigationTitle("App Information")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(AppTheme.accent)
                }
            }
            .toolbarBackground(AppTheme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    private func creditRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.mutedInk)
            Text(value)
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    CreditsView()
}
