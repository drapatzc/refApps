import Foundation
import SQLite3

/// SQLite3 database manager — manages connection and schema
final class DatabaseManager {

    private var db: OpaquePointer?
    private let dbPath: String

    // MARK: - Initialization

    /// Production initialization — uses Documents directory
    convenience init() throws {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let path = docs.appendingPathComponent("users.sqlite").path
        try self.init(path: path)
    }

    /// Initialization with explicit path (also `:memory:` for tests)
    init(path: String) throws {
        self.dbPath = path
        try openDatabase()
        try createTables()
    }

    deinit {
        if db != nil {
            sqlite3_close(db)
        }
    }

    // MARK: - Database Connection

    private func openDatabase() throws {
        let flags = SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX
        let result = sqlite3_open_v2(dbPath, &db, flags, nil)
        guard result == SQLITE_OK else {
            let msg = String(cString: sqlite3_errmsg(db))
            throw AppError.databaseOpenFailed(msg)
        }
        // WAL mode for better concurrency
        sqlite3_exec(db, "PRAGMA journal_mode=WAL;", nil, nil, nil)
    }

    private func createTables() throws {
        let sql = """
        CREATE TABLE IF NOT EXISTS users (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            salutation  TEXT    NOT NULL,
            first_name  TEXT    NOT NULL,
            last_name   TEXT    NOT NULL,
            street      TEXT    NOT NULL,
            house_number TEXT   NOT NULL,
            postal_code TEXT    NOT NULL,
            city        TEXT    NOT NULL,
            country     TEXT    NOT NULL,
            email       TEXT    NOT NULL DEFAULT ''
        );
        """
        let result = sqlite3_exec(db, sql, nil, nil, nil)
        guard result == SQLITE_OK else {
            let msg = String(cString: sqlite3_errmsg(db))
            throw AppError.databaseQueryFailed(msg)
        }
    }

    // MARK: - CRUD

    func insertUser(_ user: User) throws -> Int64 {
        let sql = """
        INSERT INTO users (salutation, first_name, last_name, street, house_number, postal_code, city, country, email)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            let msg = String(cString: sqlite3_errmsg(db))
            throw AppError.databaseInsertFailed(msg)
        }
        defer { sqlite3_finalize(stmt) }

        bindText(stmt, 1, user.salutation.rawValue)
        bindText(stmt, 2, user.firstName)
        bindText(stmt, 3, user.lastName)
        bindText(stmt, 4, user.street)
        bindText(stmt, 5, user.houseNumber)
        bindText(stmt, 6, user.postalCode)
        bindText(stmt, 7, user.city)
        bindText(stmt, 8, user.country)
        bindText(stmt, 9, user.email)

        guard sqlite3_step(stmt) == SQLITE_DONE else {
            let msg = String(cString: sqlite3_errmsg(db))
            throw AppError.databaseInsertFailed(msg)
        }
        return sqlite3_last_insert_rowid(db)
    }

    func updateUser(_ user: User) throws {
        let sql = """
        UPDATE users SET
            salutation   = ?,
            first_name   = ?,
            last_name    = ?,
            street       = ?,
            house_number = ?,
            postal_code  = ?,
            city         = ?,
            country      = ?,
            email        = ?
        WHERE id = ?;
        """
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            let msg = String(cString: sqlite3_errmsg(db))
            throw AppError.databaseUpdateFailed(msg)
        }
        defer { sqlite3_finalize(stmt) }

        bindText(stmt, 1, user.salutation.rawValue)
        bindText(stmt, 2, user.firstName)
        bindText(stmt, 3, user.lastName)
        bindText(stmt, 4, user.street)
        bindText(stmt, 5, user.houseNumber)
        bindText(stmt, 6, user.postalCode)
        bindText(stmt, 7, user.city)
        bindText(stmt, 8, user.country)
        bindText(stmt, 9, user.email)
        sqlite3_bind_int64(stmt, 10, user.id)

        guard sqlite3_step(stmt) == SQLITE_DONE else {
            let msg = String(cString: sqlite3_errmsg(db))
            throw AppError.databaseUpdateFailed(msg)
        }
    }

    func deleteUser(id: Int64) throws {
        let sql = "DELETE FROM users WHERE id = ?;"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            let msg = String(cString: sqlite3_errmsg(db))
            throw AppError.databaseDeleteFailed(msg)
        }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_int64(stmt, 1, id)
        guard sqlite3_step(stmt) == SQLITE_DONE else {
            let msg = String(cString: sqlite3_errmsg(db))
            throw AppError.databaseDeleteFailed(msg)
        }
    }

    func fetchAllUsers() throws -> [User] {
        let sql = "SELECT id, salutation, first_name, last_name, street, house_number, postal_code, city, country, email FROM users ORDER BY last_name, first_name;"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            let msg = String(cString: sqlite3_errmsg(db))
            throw AppError.databaseQueryFailed(msg)
        }
        defer { sqlite3_finalize(stmt) }

        var users: [User] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            if let user = rowToUser(stmt) {
                users.append(user)
            }
        }
        return users
    }

    func fetchUser(id: Int64) throws -> User? {
        let sql = "SELECT id, salutation, first_name, last_name, street, house_number, postal_code, city, country, email FROM users WHERE id = ?;"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            let msg = String(cString: sqlite3_errmsg(db))
            throw AppError.databaseQueryFailed(msg)
        }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_int64(stmt, 1, id)
        if sqlite3_step(stmt) == SQLITE_ROW {
            return rowToUser(stmt)
        }
        return nil
    }

    func searchUsers(query: String) throws -> [User] {
        let sql = """
        SELECT id, salutation, first_name, last_name, street, house_number, postal_code, city, country, email
        FROM users
        WHERE first_name LIKE ? OR last_name LIKE ? OR email LIKE ? OR city LIKE ?
        ORDER BY last_name, first_name;
        """
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            let msg = String(cString: sqlite3_errmsg(db))
            throw AppError.databaseQueryFailed(msg)
        }
        defer { sqlite3_finalize(stmt) }

        let pattern = "%\(query)%"
        bindText(stmt, 1, pattern)
        bindText(stmt, 2, pattern)
        bindText(stmt, 3, pattern)
        bindText(stmt, 4, pattern)

        var users: [User] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            if let user = rowToUser(stmt) {
                users.append(user)
            }
        }
        return users
    }

    // MARK: - Helpers

    // MARK: - Debug

#if DEBUG
    func deleteAllUsers() throws {
        let sql = "DELETE FROM users;"
        guard sqlite3_exec(db, sql, nil, nil, nil) == SQLITE_OK else {
            let msg = String(cString: sqlite3_errmsg(db))
            throw AppError.databaseDeleteFailed(msg)
        }
    }
#endif

    private func bindText(_ stmt: OpaquePointer?, _ index: Int32, _ value: String) {
        sqlite3_bind_text(stmt, index, (value as NSString).utf8String, -1, nil)
    }

    private func rowToUser(_ stmt: OpaquePointer?) -> User? {
        let id = sqlite3_column_int64(stmt, 0)
        let salutationRaw = String(cString: sqlite3_column_text(stmt, 1))
        let firstName = String(cString: sqlite3_column_text(stmt, 2))
        let lastName = String(cString: sqlite3_column_text(stmt, 3))
        let street = String(cString: sqlite3_column_text(stmt, 4))
        let houseNumber = String(cString: sqlite3_column_text(stmt, 5))
        let postalCode = String(cString: sqlite3_column_text(stmt, 6))
        let city = String(cString: sqlite3_column_text(stmt, 7))
        let country = String(cString: sqlite3_column_text(stmt, 8))
        let email = String(cString: sqlite3_column_text(stmt, 9))

        guard let salutation = Salutation(rawValue: salutationRaw) else { return nil }

        return User(
            id: id,
            salutation: salutation,
            firstName: firstName,
            lastName: lastName,
            street: street,
            houseNumber: houseNumber,
            postalCode: postalCode,
            city: city,
            country: country,
            email: email
        )
    }
}
