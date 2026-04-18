import XCTest
@testable import App4_iOS_UserManagement

@MainActor
final class UserListViewModelTests: XCTestCase {

    var mockRepository: MockUserRepository!
    var service: UserService!
    var sut: UserListViewModel!

    override func setUp() {
        super.setUp()
        mockRepository = MockUserRepository()
        service = UserService(repository: mockRepository)
        sut = UserListViewModel(service: service)
    }

    override func tearDown() {
        mockRepository.reset()
        service = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - loadUsers

    func test_loadUsers_populatesUsers() async {
        mockRepository.addUser(User.makeTest(firstName: "Max"))
        mockRepository.addUser(User.makeTest(firstName: "Anna"))

        await sut.loadUsers()

        XCTAssertEqual(sut.users.count, 2)
        XCTAssertNil(sut.errorMessage)
    }

    func test_loadUsers_emptyDB_setsEmptyArray() async {
        await sut.loadUsers()
        XCTAssertTrue(sut.users.isEmpty)
    }

    func test_loadUsers_repositoryError_setsErrorMessage() async {
        mockRepository.shouldThrowOnFetch = true
        await sut.loadUsers()
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.users.isEmpty)
    }

    func test_loadUsers_setsIsLoadingCorrectly() async {
        await sut.loadUsers()
        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - Suche

    func test_search_emptyQuery_returnsAll() async {
        mockRepository.addUser(User.makeTest(firstName: "A"))
        mockRepository.addUser(User.makeTest(firstName: "B"))
        await sut.loadUsers()

        sut.searchText = ""
        // Brief delay to wait for debouncing
        try? await Task.sleep(nanoseconds: 400_000_000)
        XCTAssertEqual(sut.users.count, 2)
    }

    // MARK: - requestDelete / confirmDelete

    func test_requestDelete_setsUserToDelete() {
        let user = User.makeTest(id: 1)
        sut.requestDelete(user: user)
        XCTAssertEqual(sut.userToDelete?.id, 1)
        XCTAssertTrue(sut.showDeleteConfirmation)
    }

    func test_confirmDelete_removesUserFromList() async {
        var user = User.makeTest()
        mockRepository.addUser(user)
        user = (try? await mockRepository.fetchAll())?.first ?? user

        await sut.loadUsers()
        XCTAssertEqual(sut.users.count, 1)

        sut.requestDelete(user: sut.users[0])
        await sut.confirmDelete()

        XCTAssertTrue(sut.users.isEmpty)
        XCTAssertNil(sut.userToDelete)
    }

    func test_confirmDelete_repositoryError_setsErrorMessage() async {
        let user = User.makeTest(id: 99)
        sut.users = [user]
        sut.userToDelete = user
        mockRepository.shouldThrowOnDelete = true

        await sut.confirmDelete()

        XCTAssertNotNil(sut.errorMessage)
    }

    func test_cancelDelete_clearsUserToDelete() {
        sut.userToDelete = User.makeTest(id: 1)
        sut.showDeleteConfirmation = true

        sut.cancelDelete()

        XCTAssertNil(sut.userToDelete)
        XCTAssertFalse(sut.showDeleteConfirmation)
    }

    // MARK: - userWasCreated / userWasUpdated

    func test_userWasCreated_addsToList() {
        sut.users = []
        let newUser = User.makeTest(id: 1, firstName: "Neu")
        sut.userWasCreated(newUser)
        XCTAssertEqual(sut.users.count, 1)
        XCTAssertEqual(sut.users.first?.firstName, "Neu")
    }

    func test_userWasUpdated_updatesExistingUser() {
        var user = User.makeTest(id: 1, firstName: "Alt")
        sut.users = [user]
        user.firstName = "Neu"
        sut.userWasUpdated(user)
        XCTAssertEqual(sut.users.first?.firstName, "Neu")
    }

    func test_userWasCreated_sortsByLastName() {
        let user1 = User.makeTest(id: 1, firstName: "Z", lastName: "Ziegler")
        let user2 = User.makeTest(id: 2, firstName: "A", lastName: "Amann")
        sut.userWasCreated(user1)
        sut.userWasCreated(user2)
        XCTAssertEqual(sut.users.first?.lastName, "Amann")
    }
}
