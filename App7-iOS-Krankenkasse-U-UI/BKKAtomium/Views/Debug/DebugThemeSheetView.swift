import SwiftUI

/// Debug-Sheet zur Theme-Auswahl, erreichbar über 3-Sekunden-Langdruck auf das App-Logo.
///
/// **Zweck:** Ermöglicht Entwicklern und Testern, das aktive Theme zur Laufzeit zu wechseln,
/// ohne die App neu zu kompilieren. Die Auswahl wird in `UserDefaults` gespeichert und beim
/// nächsten App-Start angewendet.
///
/// **Verhalten:**
/// - Zeigt alle verfügbaren Themes als auswählbare Listeneinträge an.
/// - Nach Auswahl erscheint ein Hinweistext mit der Information, dass ein Neustart nötig ist.
/// - Das Sheet kann über "Schließen" oder Wischgeste geschlossen werden.
///
/// **Abhängigkeiten:** `AppThemeManager` via `@Environment`.
struct DebugThemeSheetView: View {

    /// Der zentrale Theme-Manager — wird aus der Environment gelesen.
    @Environment(AppThemeManager.self) private var themeManager

    /// Steuert das Sheet von außen (z. B. aus dem Login-Screen).
    @Binding var isPresented: Bool

    /// Der Name des gerade ausgewählten Themes (für die Hervorhebung in der Liste).
    @State private var selectedThemeName: String = UserDefaults.standard.string(
        forKey: AppThemeManager.selectedThemeKey
    ) ?? "default"

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(themeManager.availableThemeNames, id: \.self) { themeName in
                        ThemeRowView(
                            themeName: themeName,
                            isSelected: themeName == selectedThemeName
                        ) {
                            selectTheme(named: themeName)
                        }
                    }
                } header: {
                    Text(String(localized: "debug_theme_section_header"))
                } footer: {
                    Text(String(localized: "debug_theme_section_footer"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(String(localized: "debug_theme_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "debug_theme_close_button")) {
                        isPresented = false
                    }
                }
            }
        }
    }

    // MARK: - Private Hilfsmethoden

    /// Wählt ein Theme aus, speichert es und wendet es sofort an.
    private func selectTheme(named name: String) {
        selectedThemeName = name
        Task {
            await themeManager.setTheme(named: name)
        }
    }
}

// MARK: - ThemeRowView

/// Einzelne Zeile im Theme-Auswahl-Sheet.
///
/// Zeigt den Anzeigenamen des Themes und einen Haken wenn es ausgewählt ist.
private struct ThemeRowView: View {

    let themeName: String
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(displayName(for: themeName))
                        .font(.body)
                        .foregroundStyle(.primary)
                    Text(themeName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(AppTheme.primary)
                        .fontWeight(.semibold)
                }
            }
        }
        .buttonStyle(.plain)
    }

    /// Gibt den lokalisierten Anzeigenamen für einen Theme-Namen zurück.
    private func displayName(for name: String) -> String {
        switch name {
        case "default": return String(localized: "debug_theme_name_default")
        case "ocean":   return String(localized: "debug_theme_name_ocean")
        case "forest":  return String(localized: "debug_theme_name_forest")
        default:        return name.capitalized
        }
    }
}
