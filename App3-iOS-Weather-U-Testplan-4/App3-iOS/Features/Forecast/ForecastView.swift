// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import SwiftUI

/// View for the 7-day weather forecast of a city.
/// Displays a list of `VorhersageZeile` rows, one per day, showing date,
/// condition icon, rain probability, and min/max temperature range.
struct ForecastView: View {

    /// View model that loads and exposes the 7-day forecast.
    @State var viewModel: ForecastViewModel
    /// The city whose forecast is displayed.
    let stadt: City

    /// Root body switching between loading indicator, forecast list, and empty state.
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView(String(localized: "loading_forecast"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.vorhersagen.isEmpty {
                Text(String(localized: "no_forecast"))
                    .foregroundStyle(.secondary)
            } else {
                List(viewModel.vorhersagen) { vorhersage in
                    VorhersageZeile(vorhersage: vorhersage)
                }
            }
        }
        .navigationTitle(String(localized: "forecast_title"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.vorhersageLaden(fuer: stadt)
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

// MARK: - Forecast Row

/// A single row in the forecast list displaying date, condition icon,
/// rain probability, and the min/max temperature range for one day.
private struct VorhersageZeile: View {
    /// The daily forecast data this row represents.
    let vorhersage: DailyForecast

    /// Body rendering date, condition icon, rain percentage, and temperature range in a horizontal stack.
    var body: some View {
        HStack(spacing: 12) {
            Text(vorhersage.datumKurz)
                .font(.subheadline)
                .frame(width: 110, alignment: .leading)

            Image(systemName: vorhersage.bedingung.systemSymbol)
                .font(.title3)
                .symbolRenderingMode(.multicolor)
                .frame(width: 32)

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "drop.fill")
                    .font(.caption2)
                    .foregroundStyle(.blue)
                Text("\(vorhersage.regenWahrscheinlichkeit) %")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 48)

            HStack(spacing: 2) {
                Text(String(format: "%.0f°", vorhersage.minTemperatur))
                    .foregroundStyle(.secondary)
                Text("/")
                    .foregroundStyle(.secondary)
                Text(String(format: "%.0f°", vorhersage.maxTemperatur))
                    .bold()
            }
            .font(.subheadline)
            .frame(width: 70, alignment: .trailing)
        }
        .padding(.vertical, 4)
    }
}
