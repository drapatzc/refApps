import Testing
import Foundation
@testable import App1_iOS

/// Tests for the InMemoryTodoRepository implementation.
struct TodoRepositoryTests {

    private func makeSUT() -> InMemoryTodoRepository {
        InMemoryTodoRepository()
    }

    // MARK: - Empty State

    @Test("Empty repository returns empty list")
    func emptyRepositoryReturnsEmptyList() {
        let sut = makeSUT()
        #expect(sut.fetchAll().isEmpty)
    }

    // MARK: - Saving

    @Test("Saved todo is retrievable")
    func savedTodoIsRetrievable() {
        let sut = makeSUT()
        let todo = Todo(title: "Test Todo")
        sut.save(todo)
        let fetched = sut.fetchAll()
        #expect(fetched.count == 1)
        #expect(fetched.first?.id == todo.id)
        #expect(fetched.first?.title == "Test Todo")
    }

    @Test("Multiple todos are saved")
    func multipleTodosAreSaved() {
        let sut = makeSUT()
        sut.save(Todo(title: "Erster"))
        sut.save(Todo(title: "Zweiter"))
        #expect(sut.fetchAll().count == 2)
    }

    // MARK: - Updating

    @Test("Updated todo is correctly saved")
    func updatedTodoIsCorrectlySaved() {
        let sut = makeSUT()
        var todo = Todo(title: "Original")
        sut.save(todo)
        todo.isCompleted = true
        sut.update(todo)
        #expect(sut.fetchAll().first?.isCompleted == true)
    }

    @Test("Updating a non-existent todo has no effect")
    func updateOfNonExistentTodoHasNoEffect() {
        let sut = makeSUT()
        let todo = Todo(title: "Nicht vorhanden")
        sut.update(todo) // should not throw
        #expect(sut.fetchAll().isEmpty)
    }

    // MARK: - Deleting

    @Test("Deleted todo is no longer present")
    func deletedTodoIsNoLongerPresent() {
        let sut = makeSUT()
        let todo = Todo(title: "Zu löschen")
        sut.save(todo)
        sut.delete(id: todo.id)
        #expect(sut.fetchAll().isEmpty)
    }

    @Test("Deleting a non-existent todo has no effect")
    func deletingNonExistentTodoHasNoEffect() {
        let sut = makeSUT()
        sut.save(Todo(title: "Vorhandenes Todo"))
        sut.delete(id: UUID()) // unknown ID
        #expect(sut.fetchAll().count == 1)
    }

    // MARK: - Sorting

    @Test("Todos are returned sorted by creation date")
    func todosAreSortedByCreationDate() {
        let sut = makeSUT()
        let first = Todo(title: "Erster", createdAt: Date(timeIntervalSince1970: 1000))
        let second = Todo(title: "Zweiter", createdAt: Date(timeIntervalSince1970: 2000))
        sut.save(second)
        sut.save(first)
        let fetched = sut.fetchAll()
        #expect(fetched[0].title == "Erster")
        #expect(fetched[1].title == "Zweiter")
    }
}
