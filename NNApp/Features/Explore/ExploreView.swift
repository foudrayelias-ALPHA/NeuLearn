import SwiftUI

struct ExploreView: View {
    @State private var searchText = ""
    @State private var selectedNode: TopicTreeNode?

    private let root = SampleContent.topicTree

    var body: some View {
        NavigationStack {
            Group {
                if normalizedQuery.isEmpty {
                    TopicTreeView(root: root)
                } else {
                    searchResultsView
                }
            }
            .background(AppBackground())
            .navigationTitle("Explore")
            .toolbarBackground(AppTheme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .searchable(text: $searchText, prompt: "Search topics and lessons")
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

    private var normalizedQuery: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines).localizedLowercase
    }

    private var searchResults: [TopicSearchResult] {
        guard !normalizedQuery.isEmpty else { return [] }

        return flattenedNodes(from: root)
            .compactMap { item in
                let lesson = SampleContent.lesson(for: item.node)
                let haystack = [
                    item.node.label,
                    item.node.summary,
                    lesson?.title,
                    lesson?.summary,
                ]
                .compactMap { $0?.localizedLowercase }
                .joined(separator: " ")

                guard haystack.contains(normalizedQuery) else { return nil }

                return TopicSearchResult(node: item.node, path: item.path, lesson: lesson)
            }
            .sorted { lhs, rhs in
                if lhs.lesson != nil && rhs.lesson == nil {
                    return true
                }

                if lhs.lesson == nil && rhs.lesson != nil {
                    return false
                }

                return lhs.node.label.localizedCaseInsensitiveCompare(rhs.node.label) == .orderedAscending
            }
    }

    private var searchResultsView: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 14) {
                if searchResults.isEmpty {
                    ContentUnavailableView(
                        "No Matches",
                        systemImage: "magnifyingglass",
                        description: Text("Try a broader term like transformers, clustering, or gradient descent.")
                    )
                    .padding(.top, 40)
                } else {
                    ForEach(searchResults) { result in
                        Button {
                            selectedNode = result.node
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 10) {
                                    Image(systemName: result.node.icon)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(AppTheme.accent)
                                        .frame(width: 24, height: 24)
                                        .background(
                                            AppTheme.accent.opacity(0.10),
                                            in: RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        )

                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(result.node.label)
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            .foregroundStyle(AppTheme.ink)

                                        Text(result.path)
                                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                                            .foregroundStyle(AppTheme.mutedInk)
                                            .lineLimit(1)
                                    }

                                    Spacer(minLength: 0)

                                    if result.lesson != nil {
                                        Image(systemName: "book.fill")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundStyle(AppTheme.accent.opacity(0.7))
                                    }
                                }

                                Text(result.lesson?.summary ?? result.node.summary)
                                    .font(.system(size: 14, weight: .regular, design: .serif))
                                    .foregroundStyle(AppTheme.mutedInk)
                                    .lineLimit(3)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(AppTheme.surface.opacity(0.96))
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(AppTheme.ink.opacity(0.06), lineWidth: 1)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 80)
        }
        .scrollContentBackground(.hidden)
        .background(AppBackground())
    }

    private func flattenedNodes(
        from node: TopicTreeNode,
        path: [String] = []
    ) -> [(node: TopicTreeNode, path: String)] {
        let currentPath = path + [node.label]
        let current = (node: node, path: currentPath.joined(separator: " / "))
        let descendants = node.children.flatMap { child in
            flattenedNodes(from: child, path: currentPath)
        }

        return [current] + descendants
    }
}

private struct TopicSearchResult: Identifiable {
    let node: TopicTreeNode
    let path: String
    let lesson: Lesson?

    var id: UUID { node.id }
}

#Preview {
    ExploreView()
        .environment(ProgressStore())
}
