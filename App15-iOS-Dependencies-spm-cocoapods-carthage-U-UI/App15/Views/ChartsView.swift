import SwiftUI
import DGCharts

struct ChartsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("DGCharts Statistics").font(.headline)
            BarChartRepresentable()
                .frame(height: 200)
        }
        .navigationTitle("DGCharts")
    }
}

struct BarChartRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> BarChartView {
        let chart = BarChartView()
        let entries = (1...5).map { BarChartDataEntry(x: Double($0), y: Double.random(in: 1...10)) }
        let set = BarChartDataSet(entries: entries, label: "Sample")
        chart.data = BarChartData(dataSet: set)
        return chart
    }
    func updateUIView(_ uiView: BarChartView, context: Context) {}
}
