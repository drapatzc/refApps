// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import SwiftUI

/// View for the current weather of a city.
/// Shows a loading spinner while data is being fetched, then displays
/// the temperature, weather condition icon, and detail cards (humidity,
/// wind, visibility, UV index). A toolbar button navigates to `ForecastView`.
struct CurrentWeatherView: View {

    /// View model that loads and exposes current weather data.
    @State var viewModel: CurrentWeatherViewModel
    /// View model for the 7-day forecast, passed forward to `ForecastView`.
    @State var forecastViewModel: ForecastViewModel
    /// The city whose weather is displayed.
    let stadt: City

    /// Root body switching between loading indicator, weather content, and empty state.
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView(String(localized: "loading_weather"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let wetter = viewModel.aktuellesWetter {
                WetterInhalt(wetter: wetter)
            } else {
                Text(String(localized: "no_weather_data"))
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(stadt.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    ForecastView(viewModel: forecastViewModel, stadt: stadt)
                } label: {
                    Label(String(localized: "forecast_button_label"), systemImage: "calendar")
                }
                .accessibilityIdentifier("vorhersageButton")
            }
        }
        .task {
            await viewModel.wetterLaden(fuer: stadt)
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

// MARK: - Weather Content

/// Scrollable container that composes the main display section and the detail cards.
private struct WetterInhalt: View {
    /// The weather data to display.
    let wetter: CurrentWeather

    /// Body arranging `HauptanzeigeSektionView` and `DetailKartenSektionView` vertically.
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                HauptanzeigeSektionView(wetter: wetter)
                DetailKartenSektionView(wetter: wetter)
            }
            .padding(.bottom, 32)
        }
    }
}

// MARK: - Main Display Section

/// Hero section showing the SF Symbol icon, large temperature, condition label,
/// and feels-like temperature.
private struct HauptanzeigeSektionView: View {
    /// The weather data to display.
    let wetter: CurrentWeather

    /// Body rendering the large weather icon, temperature, and description texts.
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: wetter.bedingung.systemSymbol)
                .font(.system(size: 80))
                .symbolRenderingMode(.multicolor)
                .accessibilityIdentifier("wetterSymbol")

            Text(wetter.temperaturFormatiert)
                .font(.system(size: 72, weight: .thin, design: .rounded))
                .accessibilityIdentifier("temperaturLabel")

            Text(wetter.bedingung.beschreibung)
                .font(.title2)
                .foregroundStyle(.secondary)

            Text(String(format: String(localized: "feels_like"), wetter.gefuehlteTemperaturFormatiert))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 24)
    }
}

// MARK: - Detail Cards Section

/// Two-column grid of `WetterDetailKarte` cards showing humidity, wind,
/// visibility, and UV index.
private struct DetailKartenSektionView: View {
    /// The weather data providing values for each card.
    let wetter: CurrentWeather

    /// Body rendering a 2-column `LazyVGrid` with four detail cards.
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            WetterDetailKarte(
                symbol: "humidity.fill",
                titel: String(localized: "humidity"),
                wert: "\(wetter.luftfeuchtigkeit) %"
            )
            WetterDetailKarte(
                symbol: "wind",
                titel: String(localized: "wind"),
                wert: "\(String(format: "%.0f", wetter.windgeschwindigkeit)) km/h \(wetter.windrichtung)"
            )
            WetterDetailKarte(
                symbol: "eye.fill",
                titel: String(localized: "visibility"),
                wert: "\(String(format: "%.0f", wetter.sichtweite)) km"
            )
            WetterDetailKarte(
                symbol: "sun.max.fill",
                titel: String(localized: "uv_index"),
                wert: "\(wetter.uvIndex)"
            )
        }
        .padding(.horizontal)
    }
}

// MARK: - Weather Detail Card

/// Rounded card showing a single weather metric with icon, label, and value.
private struct WetterDetailKarte: View {
    /// SF Symbol name for the metric icon.
    let symbol: String
    /// Localised label displayed below the icon (e.g. "Humidity").
    let titel: String
    /// Formatted value string displayed prominently (e.g. "60 %").
    let wert: String

    /// Body rendering the icon, label, and value stacked vertically in a rounded card.
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: symbol)
                .font(.title2)
                .foregroundStyle(.blue)
            Text(titel)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(wert)
                .font(.subheadline)
                .bold()
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
