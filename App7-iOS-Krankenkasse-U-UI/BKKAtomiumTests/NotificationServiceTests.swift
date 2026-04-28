import Testing
import UserNotifications
@testable import BKKAtomium

@Suite("NotificationService Tests")
struct NotificationServiceTests {

    @Test("NotificationService.shared ist zugänglich")
    func testSharedInstanceAccessible() {
        let service = NotificationService.shared
        _ = service
        #expect(Bool(true))
    }

    @Test("cancelAllNotifications() läuft ohne Absturz")
    func testCancelAllNotificationsDoesNotCrash() {
        NotificationService.shared.cancelAllNotifications()
        #expect(Bool(true))
    }

    @Test("scheduleLocalNotification() mit langer Verzögerung läuft ohne Absturz")
    func testScheduleLocalNotificationDoesNotCrash() {
        NotificationService.shared.scheduleLocalNotification(
            id: "unit_test_\(UUID().uuidString)",
            title: "Test",
            body: "Testnachricht",
            delay: 3600
        )
        #expect(Bool(true))
    }

    @Test("scheduleDemoNotification() läuft ohne Absturz")
    func testScheduleDemoNotificationDoesNotCrash() {
        NotificationService.shared.scheduleDemoNotification()
        #expect(Bool(true))
    }

    @Test("clearBadge() läuft ohne Absturz")
    func testClearBadgeDoesNotCrash() {
        NotificationService.shared.clearBadge()
        #expect(Bool(true))
    }

    @Test("authorizationStatus() gibt gültigen Status zurück")
    func testAuthorizationStatusReturnsValidValue() async {
        let status = await NotificationService.shared.authorizationStatus()
        let validStatuses: [UNAuthorizationStatus] = [
            .notDetermined, .denied, .authorized, .provisional, .ephemeral
        ]
        #expect(validStatuses.contains(status))
    }

    @Test("scheduleLocalNotification() mit Default-ID läuft ohne Absturz")
    func testScheduleLocalNotificationDefaultId() {
        NotificationService.shared.scheduleLocalNotification(
            title: "Kein-ID-Test",
            body: "Automatisch generierte ID",
            delay: 3600
        )
        #expect(Bool(true))
    }

    @Test("cancelAllNotifications() nach scheduleLocalNotification() läuft fehlerfrei")
    func testCancelAfterSchedule() {
        NotificationService.shared.scheduleLocalNotification(
            id: "cancel_test_\(UUID().uuidString)",
            title: "Abbrechen",
            body: "Dieser wird sofort abgebrochen",
            delay: 3600
        )
        NotificationService.shared.cancelAllNotifications()
        #expect(Bool(true))
    }
}
