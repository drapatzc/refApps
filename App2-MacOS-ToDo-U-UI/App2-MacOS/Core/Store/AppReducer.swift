import Foundation

/// Pure function that computes a new state from the current state and an action.
/// The reducer is the core of the Redux pattern:
/// - No side effects
/// - No external dependencies
/// - Same input → same output (deterministic)
func appReducer(state: AppState, action: AppAction) -> AppState {
    var newState = state

    switch action {

    case let .addTask(title, description, priority, dueDate, category, tags):
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            newState.errorMessage = String(localized: "error_empty_title")
            return newState
        }
        let newTask = WorkTask(
            title: trimmedTitle,
            taskDescription: description,
            priority: priority,
            dueDate: dueDate,
            tags: tags,
            category: category
        )
        newState.tasks.append(newTask)
        newState.isAddTaskPresented = false
        newState.errorMessage = nil

    case let .updateTask(id, title, description, priority, status, dueDate, category, tags):
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            newState.errorMessage = String(localized: "error_empty_title")
            return newState
        }
        if let index = newState.tasks.firstIndex(where: { $0.id == id }) {
            newState.tasks[index].title = trimmedTitle
            newState.tasks[index].taskDescription = description
            newState.tasks[index].priority = priority
            newState.tasks[index].status = status
            newState.tasks[index].dueDate = dueDate
            newState.tasks[index].category = category
            newState.tasks[index].tags = tags
        }
        newState.isEditTaskPresented = false
        newState.editingTaskID = nil
        newState.errorMessage = nil

    case let .updateTaskStatus(id, newStatus):
        if let index = newState.tasks.firstIndex(where: { $0.id == id }) {
            newState.tasks[index].status = newStatus
        }

    case let .deleteTask(id):
        newState.tasks.removeAll { $0.id == id }
        if newState.selectedTaskID == id {
            newState.selectedTaskID = nil
        }

    case let .selectTask(id):
        newState.selectedTaskID = id

    case let .setFilter(status):
        newState.filterStatus = status

    case let .setCategoryFilter(category):
        newState.filterCategory = category

    case let .setSearchQuery(query):
        newState.searchQuery = query

    case let .setSortOrder(order):
        newState.sortOrder = order

    case .showAddTask:
        newState.isAddTaskPresented = true
        newState.errorMessage = nil

    case .hideAddTask:
        newState.isAddTaskPresented = false

    case let .showEditTask(id):
        newState.editingTaskID = id
        newState.isEditTaskPresented = true
        newState.errorMessage = nil

    case .hideEditTask:
        newState.isEditTaskPresented = false
        newState.editingTaskID = nil

    case .clearError:
        newState.errorMessage = nil

    case .loadSampleData:
        newState.tasks = SampleDataProvider.makeSampleTasks()
    }

    return newState
}

// MARK: - Sample Data

/// Provides realistic sample tasks for first-launch and development.
private enum SampleDataProvider {

    // swiftlint:disable function_body_length
    static func makeSampleTasks() -> [WorkTask] {
        let calendar = Calendar.current
        let now = Date()

        func date(_ days: Int) -> Date {
            calendar.date(byAdding: .day, value: days, to: now) ?? now
        }

        return [
            WorkTask(
                title: "App Store Release vorbereiten",
                taskDescription: "Screenshots, Release Notes und Metadaten für Version 2.0 aktualisieren.",
                priority: .high,
                status: .inProgress,
                dueDate: date(3),
                tags: ["release", "app-store"],
                category: .work,
                createdAt: date(-5)
            ),
            WorkTask(
                title: "Unit Tests schreiben",
                taskDescription: "Tests für alle neuen Services und Reducer-Aktionen erstellen.",
                priority: .high,
                status: .todo,
                dueDate: date(7),
                tags: ["testing", "qualität"],
                category: .work,
                createdAt: date(-2)
            ),
            WorkTask(
                title: "Wocheneinkauf erledigen",
                taskDescription: "Milch, Brot, Käse, Äpfel, Pasta, Tomaten und Waschmittel.",
                priority: .medium,
                status: .todo,
                dueDate: date(1),
                tags: ["einkauf"],
                category: .shopping,
                createdAt: date(-1)
            ),
            WorkTask(
                title: "Code Review durchführen",
                taskDescription: "Pull Request #42 reviewen: neues Datenbankschema und Migrationsskripte.",
                priority: .high,
                status: .todo,
                dueDate: date(2),
                tags: ["code-review", "pr"],
                category: .work,
                createdAt: date(-3)
            ),
            WorkTask(
                title: "Sportkurs buchen",
                taskDescription: "Fitnessstudio-Mitgliedschaft verlängern oder neuen Kurs für den Monat anmelden.",
                priority: .low,
                status: .todo,
                dueDate: date(14),
                tags: ["fitness"],
                category: .health,
                createdAt: date(-7)
            ),
            WorkTask(
                title: "CI/CD Pipeline konfigurieren",
                taskDescription: "GitHub Actions Workflow für automatisches Deployment einrichten.",
                priority: .medium,
                status: .done,
                dueDate: nil,
                tags: ["devops", "automation"],
                category: .work,
                createdAt: date(-14)
            ),
            WorkTask(
                title: "Arzttermin wahrnehmen",
                taskDescription: "Jährliche Vorsorgeuntersuchung beim Hausarzt.",
                priority: .high,
                status: .todo,
                dueDate: date(5),
                tags: ["arzt"],
                category: .health,
                createdAt: date(-1)
            ),
            WorkTask(
                title: "Dokumentation aktualisieren",
                taskDescription: "README und API-Dokumentation mit den neuen Endpunkten ergänzen.",
                priority: .medium,
                status: .inProgress,
                dueDate: date(10),
                tags: ["docs"],
                category: .work,
                createdAt: date(-4)
            ),
            WorkTask(
                title: "Geburtstag planen",
                taskDescription: "Restaurant reservieren, Einladungen versenden, Kuchen bestellen.",
                priority: .medium,
                status: .todo,
                dueDate: date(20),
                tags: ["feier", "planung"],
                category: .personal,
                createdAt: date(-10)
            ),
            WorkTask(
                title: "Laptop reinigen",
                taskDescription: "Tastatur und Bildschirm reinigen, Lüftungsschlitze entstauben.",
                priority: .low,
                status: .done,
                dueDate: nil,
                tags: ["wartung"],
                category: .personal,
                createdAt: date(-21)
            ),
            WorkTask(
                title: "Dependencies aktualisieren",
                taskDescription: "Swift Package Manager Pakete auf neueste Versionen updaten und Tests durchführen.",
                priority: .low,
                status: .todo,
                dueDate: date(30),
                tags: ["spm", "update"],
                category: .work,
                createdAt: date(-2)
            ),
            WorkTask(
                title: "Buch lesen: Clean Architecture",
                taskDescription: "Kapitel 4–8 zu Dependency Inversion und Layer-Trennung lesen.",
                priority: .low,
                status: .inProgress,
                dueDate: nil,
                tags: ["bildung", "bücher"],
                category: .personal,
                createdAt: date(-30)
            ),
            WorkTask(
                title: "Kühlschrank abtauen",
                taskDescription: "Tiefkühlfach abtauen und Kühlschrank gründlich reinigen.",
                priority: .medium,
                status: .todo,
                dueDate: date(7),
                tags: ["haushalt"],
                category: .personal,
                createdAt: date(-3)
            ),
            WorkTask(
                title: "Steuererklärung vorbereiten",
                taskDescription: "Belege sammeln, Lohnsteuerbescheinigung anfordern, ELSTER-Formular ausfüllen.",
                priority: .high,
                status: .todo,
                dueDate: date(45),
                tags: ["finanzen", "steuer"],
                category: .personal,
                createdAt: date(-5)
            ),
            WorkTask(
                title: "Performance-Optimierung",
                taskDescription: "Langsame Datenbankabfragen mit Instruments analysieren und optimieren.",
                priority: .medium,
                status: .todo,
                dueDate: date(14),
                tags: ["performance", "instruments"],
                category: .work,
                createdAt: date(-6)
            ),
            WorkTask(
                title: "Vitamintabletten kaufen",
                taskDescription: "Vitamin D und Omega-3 in der Apotheke besorgen.",
                priority: .low,
                status: .done,
                dueDate: nil,
                tags: ["gesundheit"],
                category: .health,
                createdAt: date(-14)
            ),
            WorkTask(
                title: "App-Onboarding erstellen",
                taskDescription: "Drei Onboarding-Screens mit Animationen für den ersten App-Start gestalten.",
                priority: .high,
                status: .todo,
                dueDate: date(8),
                tags: ["design", "onboarding"],
                category: .work,
                createdAt: date(-1)
            ),
            WorkTask(
                title: "Online-Kurs abschließen",
                taskDescription: "Swift Concurrency Kurs auf Udemy abschließen – noch 4 Module übrig.",
                priority: .medium,
                status: .inProgress,
                dueDate: date(60),
                tags: ["lernen", "swift"],
                category: .personal,
                createdAt: date(-60)
            ),
            WorkTask(
                title: "Bugfix: Crash beim Login",
                taskDescription: "App crasht auf iOS 16 beim ersten Login. Stack Trace analysieren und fixen.",
                priority: .high,
                status: .done,
                dueDate: nil,
                tags: ["bugfix", "crash"],
                category: .work,
                createdAt: date(-8)
            ),
            WorkTask(
                title: "Fahrrad warten",
                taskDescription: "Reifen aufpumpen, Kette ölen, Bremsen einstellen.",
                priority: .low,
                status: .todo,
                dueDate: date(10),
                tags: ["fahrrad", "wartung"],
                category: .personal,
                createdAt: date(-2)
            )
        ]
    }
    // swiftlint:enable function_body_length
}
