import SwiftUI

struct LibraryView: View {
    @Environment(ProgressStore.self) private var progressStore
    @State private var glossarySearch = ""
    @State private var activeSection: LibrarySection = .glossary
    @State private var selectedNode: TopicTreeNode?

    private enum LibrarySection: String, CaseIterable {
        case glossary = "Glossary"
        case saved = "Saved"
    }

    private var filteredGlossary: [TopicTreeNode] {
        if glossarySearch.isEmpty {
            return SampleContent.glossaryTopicNodes
        }
        return SampleContent.glossaryTopicNodes.filter {
            $0.label.localizedCaseInsensitiveContains(glossarySearch) ||
            $0.summary.localizedCaseInsensitiveContains(glossarySearch)
        }
    }

    private var savedLessons: [Lesson] {
        SampleContent.lessons.filter { progressStore.isSaved($0.id) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    // Section picker
                    HStack(spacing: 8) {
                        ForEach(LibrarySection.allCases, id: \.self) { section in
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    activeSection = section
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: section == .glossary ? "text.book.closed.fill" : "bookmark.fill")
                                        .font(.caption)
                                    Text(section.rawValue)
                                        .font(AppTheme.bodyFont.weight(.semibold))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    activeSection == section ? AppTheme.accent : AppTheme.surfaceStrong.opacity(0.5),
                                    in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                                )
                                .foregroundStyle(activeSection == section ? .white : AppTheme.ink)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    switch activeSection {
                    case .glossary:
                        glossarySection
                    case .saved:
                        savedSection
                    }
                }
                .padding(AppTheme.screenPadding)
            }
            .scrollContentBackground(.hidden)
            .background(AppBackground())
            .navigationTitle("Library")
            .toolbarBackground(AppTheme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationDestination(for: Lesson.self) { lesson in
                LessonDetailView(lesson: lesson)
            }
            .sheet(item: $selectedNode) { node in
                if let lesson = SampleContent.lesson(for: node) {
                    NavigationStack {
                        LessonDetailView(lesson: lesson)
                    }
                } else {
                    TopicInfoSheet(node: node)
                }
            }
        }
    }

    private var glossarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Search
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(AppTheme.mutedInk)
                TextField("Search terms...", text: $glossarySearch)
                    .font(AppTheme.bodyFont)
                    .foregroundStyle(AppTheme.ink)
                    .tint(AppTheme.ink)
                if !glossarySearch.isEmpty {
                    Button {
                        glossarySearch = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(AppTheme.mutedInk)
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AppTheme.surface)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(AppTheme.ink.opacity(0.08), lineWidth: 1)
            }

            if filteredGlossary.isEmpty {
                Text("No matching terms")
                    .font(AppTheme.bodyFont)
                    .foregroundStyle(AppTheme.mutedInk)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 32)
            } else {
                SectionCard(title: "\(filteredGlossary.count) Terms", eyebrow: "Glossary") {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(filteredGlossary) { term in
                            Button {
                                selectedNode = term
                            } label: {
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: term.icon)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(AppTheme.accent)
                                        .frame(width: 20)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(term.label)
                                            .font(AppTheme.bodyFont.weight(.semibold))
                                            .foregroundStyle(AppTheme.ink)
                                        Text(term.summary)
                                            .font(AppTheme.bodyFont)
                                            .foregroundStyle(AppTheme.mutedInk)
                                            .lineSpacing(2)
                                    }

                                    Spacer(minLength: 0)

                                    Image(systemName: "chevron.right")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(AppTheme.mutedInk.opacity(0.7))
                                        .padding(.top, 2)
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)

                            if term.id != filteredGlossary.last?.id {
                                Divider()
                                    .foregroundStyle(AppTheme.surfaceStrong)
                            }
                        }
                    }
                }
            }
        }
    }

    private var savedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if savedLessons.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "bookmark")
                        .font(.system(size: 36, weight: .light))
                        .foregroundStyle(AppTheme.mutedInk)
                    Text("No saved lessons yet")
                        .font(AppTheme.bodyFont)
                        .foregroundStyle(AppTheme.mutedInk)
                    Text("Tap the bookmark icon in any lesson to save it here.")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.mutedInk)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(savedLessons) { lesson in
                    NavigationLink(value: lesson) {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(lesson.title)
                                    .font(AppTheme.bodyFont.weight(.semibold))
                                    .foregroundStyle(AppTheme.ink)
                                Text(lesson.summary)
                                    .font(AppTheme.captionFont)
                                    .foregroundStyle(AppTheme.mutedInk)
                                    .lineLimit(1)
                            }
                            Spacer()
                            if progressStore.isCompleted(lesson.id) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(AppTheme.positive)
                            }
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(AppTheme.mutedInk)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(AppTheme.surface.opacity(0.96))
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(AppTheme.ink.opacity(0.06), lineWidth: 1)
                        }
                        .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    LibraryView()
        .environment(ProgressStore())
}
