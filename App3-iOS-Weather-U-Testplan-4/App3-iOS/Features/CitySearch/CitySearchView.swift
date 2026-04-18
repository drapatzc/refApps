// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import SwiftUI

/// Main view for city search and selection.
/// Displays all available cities in a list and enables live filtering via the
/// system search bar. Tapping a city navigates to `CurrentWeatherView`.
struct CitySearchView: View {

    /// View model that drives city loading and search filtering.
    @State var viewModel: CitySearchViewModel

    /// Root body rendering the city list with search and navigation support.
    var body: some View {
        List(viewModel.angezeigteStädte) { stadt in
            NavigationLink(value: stadt) {
                StadtZeile(stadt: stadt)
            }
            .accessibilityIdentifier("stadtZeile_\(stadt.name)")
        }
        .navigationTitle(String(localized: "weather_app_title"))
        .navigationDestination(for: City.self) { stadt in
            CurrentWeatherView(
                viewModel: DependencyContainer.shared.makeCurrentWeatherViewModel(),
                forecastViewModel: DependencyContainer.shared.makeForecastViewModel(),
                stadt: stadt
            )
        }
        .searchable(text: $viewModel.suchbegriff, prompt: String(localized: "search_prompt"))
        .onChange(of: viewModel.suchbegriff) { _, _ in
            Task { await viewModel.suchen() }
        }
        .task {
            await viewModel.alleStaedteLaden()
        }
        .overlay {
            if viewModel.angezeigteStädte.isEmpty && !viewModel.isLoading {
                LeerzustandAnsicht(suchbegriff: viewModel.suchbegriff)
            }
        }
        .alert(String(localized: "error_title"), isPresented: Binding(
            get: { viewModel.hatFehler },
            set: { if !$0 { viewModel.fehlerZurücksetzen() } }
        )) {
            Button(String(localized: "ok")) { viewModel.fehlerZurücksetzen() }
        } message: {
            Text(viewModel.fehlerMeldung ?? "")
        }
    }
}

// MARK: - City Row

/// A single row in the city list showing the city name and country.
private struct StadtZeile: View {
    /// The city displayed by this row.
    let stadt: City

    /// Body rendering city name (headline) and country (secondary subheadline).
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(stadt.name)
                .font(.headline)
            Text(stadt.land)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Empty State View

/// Overlay shown when the city list is empty — either because no cities are
/// available or because the current search term yields no results.
private struct LeerzustandAnsicht: View {
    /// The active search term; used to decide which empty-state message to show.
    let suchbegriff: String

    /// Body showing a magnifier icon and a context-sensitive message.
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text(suchbegriff.isEmpty
                 ? String(localized: "no_cities_available")
                 : String(format: String(localized: "no_results_for"), suchbegriff))
                .font(.headline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
