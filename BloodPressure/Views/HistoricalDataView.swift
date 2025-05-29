import SwiftUI
import Charts

let oneWeek: TimeInterval = 604800

struct HistoricalDataView: View {
    @EnvironmentObject var healthStore: HealthStore
    @State private var selectedPeriod: String = "2 Months"
    
    let periods: [String: TimeInterval] = [
        "1 Week": oneWeek,
        "2 Weeks": 2*oneWeek,
        "4 Weeks": 4*oneWeek,
        "2 Months": 8*oneWeek,
        "3 Months": 12*oneWeek,
        "6 Months": 26*oneWeek,
        "1 Year": 52*oneWeek,
        "2 Years": 2*52*oneWeek,
        "3 Years": 3*52*oneWeek
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Select Period", selection: $selectedPeriod) {
                    ForEach(periods.sorted { $0.value < $1.value }, id: \.key) { Text($0.key) }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                
                Text("Blood Pressure")
                if !healthStore.bloodPressureData.isEmpty {
                    Chart {
                        ForEach(healthStore.bloodPressureData, id: \.0.startDate) { (systolic, diastolic) in
                            let sys = systolic.quantity.doubleValue(for: .millimeterOfMercury())
                            let dia = diastolic.quantity.doubleValue(for: .millimeterOfMercury())
                            let pointColor: Color = (sys >= 140 || dia >= 90) ? .red : (sys >= 120 || dia >= 80) ? .orange : .green

                            LineMark(
                                x: .value("Date", systolic.startDate),
                                y: .value("Systolic", sys),
                                series: .value("Systolic", "S")
                            )
                            .foregroundStyle(.gray)

                            PointMark(
                                x: .value("Date", systolic.startDate),
                                y: .value("Systolic", sys)
                            )
                            .foregroundStyle(pointColor)
                            .symbol(by: .value("Type", "Systolic"))
                        }

                        ForEach(healthStore.bloodPressureData, id: \.0.startDate) { (systolic, diastolic) in
                            let sys = systolic.quantity.doubleValue(for: .millimeterOfMercury())
                            let dia = diastolic.quantity.doubleValue(for: .millimeterOfMercury())
                            let pointColor: Color = (sys >= 140 || dia >= 90) ? .red : (sys >= 120 || dia >= 80) ? .orange : .green

                            LineMark(
                                x: .value("Date", diastolic.startDate),
                                y: .value("Diastolic", dia),
                                series: .value("Diastolic", "D")
                            )
                            .foregroundStyle(.gray)

                            PointMark(
                                x: .value("Date", diastolic.startDate),
                                y: .value("Diastolic", dia)
                            )
                            .foregroundStyle(pointColor)
                            .symbol(by: .value("Type", "Diastolic"))
                        }

                        ForEach(healthStore.bloodPressureData, id: \.0.startDate) { (systolic, diastolic) in
                            let sys = systolic.quantity.doubleValue(for: .millimeterOfMercury())
                            let dia = diastolic.quantity.doubleValue(for: .millimeterOfMercury())
                            let map = healthStore.meanArterialPressure(systolic: sys, diastolic: dia)
                            let pointColor: Color = (map >= 110 || map <= 60) ? .red : (map >= 100 || map <= 70) ? .orange : .green

                            LineMark(
                                x: .value("Date", systolic.startDate),
                                y: .value("MAP", map),
                                series: .value("MAP", "M")
                            )
                            .foregroundStyle(.gray)

                            PointMark(
                                x: .value("Date", systolic.startDate),
                                y: .value("MAP", map)
                            )
                            .foregroundStyle(pointColor)
                            .symbol(by: .value("Type", "MAP"))
                        }
                    }
                    .chartYScale(domain: [healthStore.minDiastolic - 5, healthStore.maxSystolic + 5])
                    .padding()
                }
                else {
                    Text("No blood pressure data available")
                }
                
                Text("Heart Rate")
                if !healthStore.heartRateData.isEmpty {
                    Chart(healthStore.heartRateData, id: \.self) { sample in
                        LineMark(
                            x: .value("Date", sample.startDate),
                            y: .value("BPM", sample.quantity.doubleValue(for: .init(from: "count/min")))
                        )
                    }
                    .chartYScale(domain: [healthStore.minHeartRate - 5, healthStore.maxHeartRate + 5])
                    .padding()
                }
                else {
                    Text("No heart rate data available")
                }
            }
            .onChange(of: selectedPeriod) {
                loadData()
            }
            .onAppear() {
                loadData()
            }
            //.navigationTitle("Historical Data")
        }
    }
    private func loadData() {
        let now = Date()
        let interval: TimeInterval = periods[selectedPeriod] ?? 604800
        let start = now.addingTimeInterval(-interval)
        healthStore.fetchData(for: DateInterval(start: start, end: now)) {}
    }
}
