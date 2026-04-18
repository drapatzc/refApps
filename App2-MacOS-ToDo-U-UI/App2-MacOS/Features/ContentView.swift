import SwiftUI

/// Main view of the macOS app: NavigationSplitView with task list and detail panel.
struct ContentView: View {

    let store: AppStore

    var body: some View {
        NavigationSplitView {
            TaskListView(store: store)
        } detail: {
            if store.state.selectedTask != nil {
                TaskDetailView(store: store)
            } else {
                emptyDetailView
            }
        }
        .sheet(isPresented: Binding(
            get: { store.state.isAddTaskPresented },
            set: { _ in store.dispatch(.hideAddTask) }
        )) {
            AddTaskView(store: store)
        }
        .frame(minWidth: 700, minHeight: 450)
    }

    // MARK: - Empty Detail Panel

    private var emptyDetailView: some View {
        ContentUnavailableView(
            String(localized: "no_task_selected"),
            systemImage: "checklist",
            description: Text(String(localized: "no_task_selected_hint"))
        )
    }
}
