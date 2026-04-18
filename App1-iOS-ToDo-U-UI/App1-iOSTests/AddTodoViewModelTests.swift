import Testing
import Foundation
@testable import App1_iOS

/// Tests for AddTodoViewModel.
struct AddTodoViewModelTests {

    private func makeSUT() -> (viewModel: AddTodoViewModel, service: MockTodoService) {
        let service = MockTodoService()
        let viewModel = AddTodoViewModel(service: service)
        return (viewModel, service)
    }

    // MARK: - Validation

    @Test("Empty title is invalid")
    func emptyTitleIsInvalid() {
        let (viewModel, _) = makeSUT()
        viewModel.title = ""
        #expect(viewModel.isTitleValid == false)
    }

    @Test("Whitespace-only title is invalid")
    func whitespaceOnlyTitleIsInvalid() {
        let (viewModel, _) = makeSUT()
        viewModel.title = "   "
        #expect(viewModel.isTitleValid == false)
    }

    @Test("Non-empty title is valid")
    func nonEmptyTitleIsValid() {
        let (viewModel, _) = makeSUT()
        viewModel.title = "Mein Todo"
        #expect(viewModel.isTitleValid == true)
    }

    // MARK: - Saving (Happy Path)

    @Test("Successful save sets isSaved to true")
    func successfulSaveSetsIsSavedToTrue() {
        let (viewModel, _) = makeSUT()
        viewModel.title = "Gültiges Todo"
        viewModel.saveTodo()
        #expect(viewModel.isSaved == true)
    }

    @Test("Successful save does not set an error message")
    func successfulSaveDoesNotSetErrorMessage() {
        let (viewModel, _) = makeSUT()
        viewModel.title = "Gültiges Todo"
        viewModel.saveTodo()
        #expect(viewModel.errorMessage == nil)
    }

    @Test("Successful save delegates to service")
    func successfulSaveDelegatesToService() {
        let (viewModel, service) = makeSUT()
        viewModel.title = "Service-Test"
        viewModel.saveTodo()
        #expect(service.createCallCount == 1)
    }

    // MARK: - Saving (Error Path)

    @Test("Saving with error sets error message")
    func savingWithErrorSetsErrorMessage() {
        let (viewModel, service) = makeSUT()
        service.createShouldThrow = true
        viewModel.title = "Valider Titel"
        viewModel.saveTodo()
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isSaved == false)
    }
}
