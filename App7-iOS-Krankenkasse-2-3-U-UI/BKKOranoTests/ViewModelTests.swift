import Testing
import Foundation
@testable import BKKOrano

// MARK: - HomeViewModel

@Suite("HomeViewModel")
@MainActor
struct HomeViewModelTests {

    @Test("Greeting switches to morning before 11 o'clock")
    func greetingMorning() {
        let vm = HomeViewModel()
        let morning = Calendar.current.date(from: DateComponents(hour: 8))!
        #expect(vm.greetingForTimeOfDay(now: morning) == String(localized: "greeting_morning"))
    }

    @Test("Greeting switches to afternoon between 11 and 17")
    func greetingAfternoon() {
        let vm = HomeViewModel()
        let afternoon = Calendar.current.date(from: DateComponents(hour: 14))!
        #expect(vm.greetingForTimeOfDay(now: afternoon) == String(localized: "greeting_afternoon"))
    }

    @Test("Greeting is evening between 17 and 22")
    func greetingEvening() {
        let vm = HomeViewModel()
        let evening = Calendar.current.date(from: DateComponents(hour: 19))!
        #expect(vm.greetingForTimeOfDay(now: evening) == String(localized: "greeting_evening"))
    }

    @Test("Greeting is night otherwise")
    func greetingNight() {
        let vm = HomeViewModel()
        let lateNight = Calendar.current.date(from: DateComponents(hour: 23))!
        #expect(vm.greetingForTimeOfDay(now: lateNight) == String(localized: "greeting_night"))
    }

    @Test("Filter .all yields every discover card")
    func filterAllReturnsAll() {
        let vm = HomeViewModel()
        vm.activeFilter = .all
        #expect(vm.filteredDiscoverCards.count == vm.discoverCards.count)
    }

    @Test("Filter narrows discover feed to matching entries only")
    func filterNarrowsFeed() {
        let vm = HomeViewModel()
        vm.activeFilter = .bonus
        #expect(!vm.filteredDiscoverCards.isEmpty)
        #expect(vm.filteredDiscoverCards.allSatisfy { $0.filter == .bonus })
    }

    @Test("Search with empty text yields no results (feed is shown instead)")
    func searchEmptyYieldsNoResults() {
        let vm = HomeViewModel()
        vm.searchText = ""
        #expect(vm.searchResults.isEmpty)
    }

    @Test("Search matches against catalog titles and subtitles case-insensitively")
    func searchMatchesCatalog() {
        let vm = HomeViewModel()
        vm.searchText = "bonus"
        #expect(!vm.searchResults.isEmpty)
        #expect(vm.searchResults.contains { $0.title.lowercased().contains("bonus") })
    }

    @Test("Quick actions catalogue is not empty and points at known destinations")
    func quickActionsCatalogue() {
        let vm = HomeViewModel()
        #expect(!vm.quickActions.isEmpty)
        // Each action must declare a title and icon.
        #expect(vm.quickActions.allSatisfy { !$0.title.isEmpty && !$0.icon.isEmpty })
    }
}

// MARK: - ServiceHubViewModel

@Suite("ServiceHubViewModel")
@MainActor
struct ServiceHubViewModelTests {

    @Test("Health section is populated with at least the core tiles")
    func healthTilesNotEmpty() {
        let vm = ServiceHubViewModel()
        #expect(vm.healthTiles.count >= 3)
    }

    @Test("Document section includes a certificate-request tile")
    func documentTilesContainCertificates() {
        let vm = ServiceHubViewModel()
        #expect(vm.documentTiles.contains { $0.destination == .certificates })
    }

    @Test("Contact section links to both hotlines")
    func contactTilesIncludeBothHotlines() {
        let vm = ServiceHubViewModel()
        let destinations = vm.contactTiles.map(\.destination)
        #expect(destinations.contains(.hotlineDoctor))
        #expect(destinations.contains(.hotlineMedical))
    }

    @Test("allTiles is union of health+document+contact")
    func allTilesIsUnion() {
        let vm = ServiceHubViewModel()
        let expectedCount = vm.healthTiles.count + vm.documentTiles.count + vm.contactTiles.count
        #expect(vm.allTiles.count == expectedCount)
    }
}

// MARK: - BonusProgramViewModel

@Suite("BonusProgramViewModel")
@MainActor
struct BonusProgramViewModelTests {

    @Test("Progress is between 0 and 1 for a partial goal")
    func progressInRange() {
        let vm = BonusProgramViewModel()
        vm.goalEuro = 200
        vm.currentEuro = 50
        #expect(vm.progress >= 0.0)
        #expect(vm.progress <= 1.0)
        #expect(abs(vm.progress - 0.25) < 0.001)
    }

    @Test("Progress clamps at 1.0 when current exceeds goal")
    func progressClampsAtOne() {
        let vm = BonusProgramViewModel()
        vm.goalEuro = 200
        vm.currentEuro = 999
        #expect(vm.progress == 1.0)
    }

    @Test("formatEuro renders a whole euro amount without fractional digits")
    func formatEuroRendersWholeAmount() {
        let vm = BonusProgramViewModel()
        let formatted = vm.formatEuro(90)
        #expect(formatted.contains("90"))
        #expect(!formatted.contains(".00"))
        #expect(!formatted.contains(",00"))
    }
}
