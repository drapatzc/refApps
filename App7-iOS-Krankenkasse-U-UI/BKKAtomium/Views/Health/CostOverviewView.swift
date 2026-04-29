import SwiftUI
import Charts

private struct MonthlySpend: Identifiable {
    let id = UUID()
    let month: String
    let amount: Double
}

struct CostTransaction: Identifiable {
    let id = UUID()
    let date: String
    let description: String
    let amount: Double
    let isRefund: Bool
}

struct CostOverviewView: View {
    private let year = Calendar.current.component(.year, from: Date())
    private let totalCopay: Double = 52.50
    private let copayLimit: Double = 208.00
    private let totalRefund: Double = 0.00

    // Monatliche Ausgaben Mai 2025 – Apr 2026 (alle Kategorien summiert)
    private let monthlySpending: [MonthlySpend] = [
        MonthlySpend(month: "Mai",  amount: 125.00),
        MonthlySpend(month: "Jun",  amount:  55.00),
        MonthlySpend(month: "Jul",  amount:  32.00),
        MonthlySpend(month: "Aug",  amount:  48.00),
        MonthlySpend(month: "Sep",  amount: 120.00),
        MonthlySpend(month: "Okt",  amount:  85.50),
        MonthlySpend(month: "Nov",  amount:  22.00),
        MonthlySpend(month: "Dez",  amount: 355.00),
        MonthlySpend(month: "Jan",  amount:  10.00),
        MonthlySpend(month: "Feb",  amount: 110.50),
        MonthlySpend(month: "Mär",  amount: 335.99),
        MonthlySpend(month: "Apr",  amount: 165.00),
    ]

    private let transactions: [CostTransaction] = [
        CostTransaction(date: "14.03.2025", description: "Rezeptgebühr – Pantoprazol",    amount: 10.00, isRefund: false),
        CostTransaction(date: "10.03.2025", description: "Rezeptgebühr – Metformin",      amount: 10.00, isRefund: false),
        CostTransaction(date: "14.02.2025", description: "Praxisgebühr – Check-up 35",    amount: 0.00,  isRefund: false),
        CostTransaction(date: "22.01.2025", description: "Rezeptgebühr – Vitamin D3",     amount: 7.50,  isRefund: false),
        CostTransaction(date: "15.01.2025", description: "Zahnersatz Eigenanteil",         amount: 25.00, isRefund: false)
    ]

    private var progress: Double { min(totalCopay / copayLimit, 1.0) }
    private var remaining: Double { max(copayLimit - totalCopay, 0) }

    var body: some View {
        List {
            Section {
                VStack(spacing: AppTheme.spacingM) {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Zuzahlungen \(year)")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                            Text(formatEuro(totalCopay))
                                .font(.title.weight(.bold))
                                .foregroundStyle(AppTheme.primary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 3) {
                            Text("Belastungsgrenze")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                            Text(formatEuro(copayLimit))
                                .font(.title3.weight(.bold))
                                .foregroundStyle(.primary)
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(AppTheme.primary.opacity(0.12))
                                    .frame(height: 8)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(AppTheme.primaryGradient)
                                    .frame(width: geo.size.width * progress, height: 8)
                            }
                        }
                        .frame(height: 8)

                        Text("Noch \(formatEuro(remaining)) bis zur Belastungsgrenze")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, AppTheme.spacingXS)
                .listRowBackground(AppTheme.primary.opacity(0.04))
            }

            Section(header: Text("Monatsausgaben (Mai 2025 – Apr 2026)")) {
                Chart(monthlySpending) { item in
                    BarMark(
                        x: .value("Monat", item.month),
                        y: .value("Betrag", item.amount)
                    )
                    .foregroundStyle(
                        item.amount == monthlySpending.map(\.amount).max()
                            ? AppTheme.primary
                            : AppTheme.primary.opacity(0.55)
                    )
                    .cornerRadius(4)
                }
                .chartYAxis {
                    AxisMarks(values: .automatic(desiredCount: 4)) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let amount = value.as(Double.self) {
                                Text("\(Int(amount)) €").font(.caption2)
                            }
                        }
                    }
                }
                .frame(height: 160)
                .padding(.vertical, AppTheme.spacingS)
            }

            Section(header: Text("Jahresübersicht")) {
                summaryRow(label: "Zuzahlungen gesamt",  value: formatEuro(totalCopay),  color: Color(red: 0.80, green: 0.25, blue: 0.25))
                summaryRow(label: "Erstattungen gesamt", value: formatEuro(totalRefund), color: Color(red: 0.20, green: 0.60, blue: 0.40))
            }

            Section(header: Text("Buchungen \(year)")) {
                ForEach(transactions) { t in
                    TransactionRow(transaction: t)
                }
            }

            Section {
                Text("Diese Übersicht ist vorläufig. Maßgeblich ist Ihr jährlicher Kontoauszug.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(String(localized: "health_cost_title"))
        .navigationBarTitleDisplayMode(.large)
    }

    private func summaryRow(label: String, value: String, color: Color) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(color)
        }
    }

    private func formatEuro(_ v: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "EUR"
        return f.string(from: NSNumber(value: v)) ?? "\(v) €"
    }
}

private struct TransactionRow: View {
    let transaction: CostTransaction

    var body: some View {
        HStack(spacing: AppTheme.spacingM) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill((transaction.isRefund ? Color(red: 0.20, green: 0.60, blue: 0.40) : Color(red: 0.80, green: 0.25, blue: 0.25)).opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: transaction.isRefund ? "arrow.down.circle.fill" : "eurosign.circle.fill")
                    .font(.system(size: 15))
                    .foregroundStyle(transaction.isRefund ? Color(red: 0.20, green: 0.60, blue: 0.40) : Color(red: 0.80, green: 0.25, blue: 0.25))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.description)
                    .font(.subheadline.weight(.semibold))
                Text(transaction.date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(transaction.amount == 0 ? "—" : "\(transaction.isRefund ? "+" : "-")\(formatEuro(transaction.amount))")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(transaction.isRefund ? Color(red: 0.20, green: 0.60, blue: 0.40) : .primary)
        }
        .padding(.vertical, 3)
    }

    private func formatEuro(_ v: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "EUR"
        return f.string(from: NSNumber(value: v)) ?? "\(v) €"
    }
}

#Preview {
    NavigationStack { CostOverviewView() }
}
