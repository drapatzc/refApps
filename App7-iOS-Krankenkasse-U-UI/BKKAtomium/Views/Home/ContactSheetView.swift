import SwiftUI

/// A modal sheet presenting all available contact options for the insured person.
///
/// Shows a phone section with a direct `tel:` link, a written contact section
/// (secure message, postal address, praise/complaints, advisor), and a "more contacts" section.
struct ContactSheetView: View {
    @Environment(\.dismiss) private var dismiss

    /// A `tel:` URL used for the direct phone link. `nil` if the URL cannot be constructed.
    private var phoneURL: URL? {
        URL(string: "tel:080011112222")
    }

    /// Renders the contact list with phone, written, and more-contacts sections.
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text(String(localized: "contact_intro"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: AppTheme.spacingM,
                                                  leading: AppTheme.spacingM,
                                                  bottom: AppTheme.spacingM,
                                                  trailing: AppTheme.spacingM))
                }

                Section(header: Text(String(localized: "contact_section_phone"))) {
                    if let phoneURL {
                        Link(destination: phoneURL) {
                            ContactRow(
                                icon: "phone.fill",
                                tint: Color(red: 0.20, green: 0.60, blue: 0.40),
                                title: String(localized: "contact_service_number_title"),
                                subtitle: String(localized: "contact_service_number"),
                                showChevron: false
                            )
                        }
                    } else {
                        ContactRow(
                            icon: "phone.fill",
                            tint: Color(red: 0.20, green: 0.60, blue: 0.40),
                            title: String(localized: "contact_service_number_title"),
                            subtitle: String(localized: "contact_service_number"),
                            showChevron: false
                        )
                    }
                }

                Section(header: Text(String(localized: "contact_section_written"))) {
                    NavigationLink {
                        SecureMessageView()
                    } label: {
                        ContactRow(
                            icon: "envelope.fill",
                            tint: Color(red: 0.11, green: 0.29, blue: 0.50),
                            title: String(localized: "contact_request_title"),
                            subtitle: nil
                        )
                    }

                    NavigationLink {
                        InsuranceAddressView()
                    } label: {
                        ContactRow(
                            icon: "building.2.fill",
                            tint: Color(red: 0.10, green: 0.45, blue: 0.55),
                            title: String(localized: "contact_address_title"),
                            subtitle: String(localized: "contact_address_line1")
                                + "\n"
                                + String(localized: "contact_address_line2")
                        )
                    }

                    NavigationLink {
                        PraiseComplaintsView()
                    } label: {
                        ContactRow(
                            icon: "hand.thumbsup.fill",
                            tint: Color(red: 0.55, green: 0.25, blue: 0.75),
                            title: String(localized: "contact_praise_complaint_title"),
                            subtitle: nil
                        )
                    }

                    NavigationLink {
                        AdvisorView()
                    } label: {
                        ContactRow(
                            icon: "person.fill",
                            tint: Color(red: 0.80, green: 0.45, blue: 0.15),
                            title: String(localized: "contact_advisor_title"),
                            subtitle: nil
                        )
                    }
                }

                Section(header: Text(String(localized: "contact_section_more"))) {
                    NavigationLink {
                        MoreContactsView()
                    } label: {
                        ContactRow(
                            icon: "person.3.fill",
                            tint: Color(red: 0.35, green: 0.35, blue: 0.55),
                            title: String(localized: "contact_more_contacts_title"),
                            subtitle: nil
                        )
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(AppTheme.groupedBackground)
            .navigationTitle(String(localized: "contact_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "common_close")) {
                        dismiss()
                    }
                }
            }
        }
    }

    /// A shared placeholder view used for unimplemented contact destinations.
    private var placeholder: some View {
        PlaceholderView(
            title: String(localized: "placeholder_in_development_title"),
            icon: "hammer.fill"
        )
    }
}

// MARK: - Row

/// A single row in the contact sheet with a tinted icon, title, optional subtitle, and optional chevron.
private struct ContactRow: View {

    /// The SF Symbols icon name.
    let icon: String

    /// The tint color applied to the icon and its rounded background.
    let tint: Color

    /// The primary row title.
    let title: String

    /// An optional subtitle shown below the title. When `nil`, only the title is rendered.
    let subtitle: String?

    /// When `true`, a trailing chevron is rendered. Defaults to `true`.
    var showChevron: Bool = true

    /// Renders the icon container, text stack, and optional chevron in a horizontal layout.
    var body: some View {
        HStack(spacing: AppTheme.spacingM) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(tint.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(tint)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ContactSheetView()
}
