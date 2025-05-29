import SwiftUI

struct DataEntryView: View {
    @EnvironmentObject var healthStore: HealthStore
    @State private var systolic: String = ""
    @State private var diastolic: String = ""
    @State private var heartRate: String = ""
    @State private var selectedDate = Date()

    var body: some View {
        //NavigationView {
            Form {
                Section(header: Text("Blood Pressure (mmHg)")) {
                    TextField("Systolic (top number)", text: $systolic)
                        .keyboardType(.decimalPad)
                    TextField("Diastolic (bottom number)", text: $diastolic)
                        .keyboardType(.decimalPad)
                }

                Section(header: Text("Heart Rate (BPM)")) {
                    TextField("Heart Rate", text: $heartRate)
                        .keyboardType(.decimalPad)
                }

                Section(header: Text("Date & Time")) {
                    DatePicker("Select Date", selection: $selectedDate)
                }

                Button("Save") {
                    if let sys = Double(systolic), let dia = Double(diastolic) {
                        healthStore.saveBloodPressure(systolic: sys, diastolic: dia, date: selectedDate)
                    }
                    if let bpm = Double(heartRate) {
                        healthStore.saveHeartRate(bpm, date: selectedDate)
                    }
                }
            //}
            //.navigationTitle("Enter Data")
        }
    }
}

#Preview {
    var healthStore = HealthStore()

    DataEntryView()
        .environmentObject(healthStore)
}
