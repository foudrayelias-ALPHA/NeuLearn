import SwiftUI

// MARK: - Topic Tree View

private enum TopicTreeLayout {
    static let branchSpacing: CGFloat = 14
}

struct TopicTreeView: View {
    let root: TopicTreeNode
    @Environment(ProgressStore.self) private var progressStore
    @State private var expandedIDs: Set<UUID> = []
    @State private var selectedNode: TopicTreeNode?

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            TreeBranch(
                node: root,
                depth: 0,
                expandedIDs: $expandedIDs,
                selectedNode: $selectedNode,
                progressStore: progressStore
            )
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 80)
        }
        .scrollContentBackground(.hidden)
        .background(AppBackground())
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

// MARK: - Recursive Branch

private struct TreeBranch: View {
    let node: TopicTreeNode
    let depth: Int
    @Binding var expandedIDs: Set<UUID>
    @Binding var selectedNode: TopicTreeNode?
    let progressStore: ProgressStore

    private var isExpanded: Bool { expandedIDs.contains(node.id) }
    private var resolvedLesson: Lesson? { SampleContent.lesson(for: node) }

    var body: some View {
        VStack(alignment: .leading, spacing: TopicTreeLayout.branchSpacing) {
            TreeNodeView(
                node: node,
                depth: depth,
                isExpanded: isExpanded,
                hasLesson: resolvedLesson != nil,
                isCompleted: resolvedLesson.map { progressStore.isCompleted($0.id) } ?? false,
                onTap: {
                    if node.isLeaf {
                        selectedNode = node
                    } else {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            if isExpanded {
                                expandedIDs.remove(node.id)
                            } else {
                                expandedIDs.insert(node.id)
                            }
                        }
                    }
                },
                onInfoTap: {
                    selectedNode = node
                }
            )

            if isExpanded && !node.children.isEmpty {
                VStack(alignment: .leading, spacing: TopicTreeLayout.branchSpacing) {
                    ForEach(Array(node.children.enumerated()), id: \.element.id) { index, child in
                        HStack(alignment: .top, spacing: 0) {
                            // Connector line
                            ConnectorLine(isLast: index == node.children.count - 1, depth: depth)

                            TreeBranch(
                                node: child,
                                depth: depth + 1,
                                expandedIDs: $expandedIDs,
                                selectedNode: $selectedNode,
                                progressStore: progressStore
                            )
                        }
                    }
                }
                .padding(.leading, 18)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

// MARK: - Single Node

private struct TreeNodeView: View {
    let node: TopicTreeNode
    let depth: Int
    let isExpanded: Bool
    let hasLesson: Bool
    let isCompleted: Bool
    let onTap: () -> Void
    let onInfoTap: () -> Void

    private var depthColor: Color {
        let colors: [Color] = [
            AppTheme.accent,
            Color(red: 0.55, green: 0.27, blue: 0.52),
            AppTheme.accentWarm,
            AppTheme.positive,
            AppTheme.nodeHidden,
            AppTheme.negative,
        ]
        return colors[depth % colors.count]
    }

    private var nodeSize: CGFloat {
        max(32 - CGFloat(depth) * 2, 22)
    }

    private var fontSize: Font {
        switch depth {
        case 0: return .system(size: 19, weight: .bold, design: .serif)
        case 1: return .system(size: 16, weight: .bold, design: .rounded)
        case 2: return .system(size: 14, weight: .semibold, design: .rounded)
        default: return .system(size: 13, weight: .medium, design: .rounded)
        }
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                // Node dot / icon
                ZStack {
                    Circle()
                        .fill(
                            isCompleted
                                ? AppTheme.positive
                                : depthColor.opacity(depth == 0 ? 1.0 : 0.15)
                        )
                        .frame(width: nodeSize, height: nodeSize)

                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: nodeSize * 0.4, weight: .bold))
                            .foregroundStyle(.white)
                    } else {
                        Image(systemName: node.icon)
                            .font(.system(size: nodeSize * 0.38))
                            .foregroundStyle(depth == 0 ? .white : depthColor)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(node.label)
                            .font(fontSize)
                            .foregroundStyle(AppTheme.ink)

                        if !node.isLeaf {
                            Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(depthColor.opacity(0.6))
                        }
                    }

                }

                Spacer(minLength: 0)

                if hasLesson {
                    Image(systemName: "book.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(AppTheme.accent.opacity(0.5))
                        .padding(.trailing, 4)
                }
            }
            .padding(.vertical, depth == 0 ? 14 : 9)
            .padding(.horizontal, depth == 0 ? 16 : 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: depth == 0 ? AppTheme.cardRadius : 16, style: .continuous)
                    .fill(
                        depth == 0
                            ? AnyShapeStyle(
                                LinearGradient(
                                    colors: [depthColor.opacity(0.12), depthColor.opacity(0.04)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            : AnyShapeStyle(AppTheme.surface.opacity(0.92))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: depth == 0 ? AppTheme.cardRadius : 16, style: .continuous)
                    .stroke(
                        isCompleted ? AppTheme.positive.opacity(0.3) : depthColor.opacity(depth == 0 ? 0.2 : 0.08),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(depth == 0 ? 0.06 : 0.02), radius: depth == 0 ? 12 : 6, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Connector Lines

private struct ConnectorLine: View {
    let isLast: Bool
    let depth: Int

    private var lineColor: Color {
        let colors: [Color] = [
            AppTheme.accent.opacity(0.25),
            Color(red: 0.55, green: 0.27, blue: 0.52).opacity(0.2),
            AppTheme.accentWarm.opacity(0.2),
            AppTheme.positive.opacity(0.2),
            AppTheme.nodeHidden.opacity(0.2),
        ]
        return colors[depth % colors.count]
    }

    var body: some View {
        Canvas { context, size in
            let midX = size.width / 2
            let curveRadius: CGFloat = 10

            var path = Path()
            // Vertical line from top
            path.move(to: CGPoint(x: midX, y: 0))
            path.addLine(to: CGPoint(x: midX, y: size.height / 2 - curveRadius))

            // Curve to the right
            path.addQuadCurve(
                to: CGPoint(x: midX + curveRadius, y: size.height / 2),
                control: CGPoint(x: midX, y: size.height / 2)
            )

            // Horizontal line to the right
            path.addLine(to: CGPoint(x: size.width, y: size.height / 2))

            context.stroke(path, with: .color(lineColor), style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))

            // Continue vertical line if not last
            if !isLast {
                var cont = Path()
                cont.move(to: CGPoint(x: midX, y: size.height / 2))
                cont.addLine(to: CGPoint(x: midX, y: size.height))
                context.stroke(cont, with: .color(lineColor), style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
            }

            // Dot at the junction
            let dotRect = CGRect(x: midX - 3, y: size.height / 2 - 3, width: 6, height: 6)
            context.fill(Ellipse().path(in: dotRect), with: .color(lineColor.opacity(2.0)))
        }
        .frame(width: 28, height: 52)
    }
}

// MARK: - Info Sheet

struct TopicInfoSheet: View {
    let node: TopicTreeNode
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.accent.opacity(0.12))
                                .frame(width: 48, height: 48)
                            Image(systemName: node.icon)
                                .font(.system(size: 20))
                                .foregroundStyle(AppTheme.accent)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(node.label)
                                .font(AppTheme.titleFont)
                                .foregroundStyle(AppTheme.ink)
                            if !node.children.isEmpty {
                                Text("\(node.children.count) subtopics")
                                    .font(AppTheme.captionFont)
                                    .foregroundStyle(AppTheme.mutedInk)
                            }
                        }
                    }

                    Text(node.summary)
                        .font(AppTheme.bodyFont)
                        .foregroundStyle(AppTheme.mutedInk)
                        .lineSpacing(4)

                    if !node.children.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("SUBTOPICS")
                                .font(AppTheme.captionFont)
                                .tracking(1.2)
                                .foregroundStyle(AppTheme.accent)

                            ForEach(node.children) { child in
                                HStack(spacing: 10) {
                                    Image(systemName: child.icon)
                                        .font(.system(size: 13))
                                        .foregroundStyle(AppTheme.accent.opacity(0.6))
                                        .frame(width: 24)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(child.label)
                                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                                            .foregroundStyle(AppTheme.ink)
                                        Text(child.summary)
                                            .font(.system(size: 12, weight: .regular, design: .rounded))
                                            .foregroundStyle(AppTheme.mutedInk)
                                            .lineLimit(2)
                                    }
                                }
                                .padding(.vertical, 6)
                            }
                        }
                    }

                    if SampleContent.lesson(for: node) == nil && node.isLeaf {
                        HStack(spacing: 8) {
                            Image(systemName: "hammer.fill")
                                .foregroundStyle(AppTheme.accentWarm)
                            Text("Lesson coming soon")
                                .font(AppTheme.captionFont)
                                .foregroundStyle(AppTheme.accentWarm)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 14)
                        .background(AppTheme.accentWarm.opacity(0.08), in: Capsule())
                    }
                }
                .padding(AppTheme.screenPadding)
            }
            .scrollContentBackground(.hidden)
            .background(AppBackground())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(AppTheme.bodyFont)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    TopicTreeView(root: SampleContent.topicTree)
        .environment(ProgressStore())
}
