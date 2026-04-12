import SwiftUI

struct ExploreView: View {
    var body: some View {
        NavigationStack {
            TopicTreeView(root: SampleContent.topicTree)
                .background(AppBackground())
                .navigationTitle("Explore")
                .toolbarBackground(AppTheme.background, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .navigationDestination(for: Lesson.self) { lesson in
                    LessonDetailView(lesson: lesson)
                }
        }
    }
}

#Preview {
    ExploreView()
        .environment(ProgressStore())
}
