import SwiftUI

struct DataEntryView: View {
    @EnvironmentObject var healthStore: HealthStore
    @State private var systolic: String = ""
    @State private var diastolic: String = ""
    @State private var heartRate: String = ""
    @State private var selectedDate = Date()
    @State private var savedAlert = false

    private enum Field: Int, CaseIterable {
        case systolic
        case diastolic
        case heartRate
        case date
    }
    @FocusState private var focusedField: Field?
    var body: some View {
        Form {
            Section(header: Text("Blood Pressure (mmHg)")) {
                TextField("Systolic (top number)", text: $systolic)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .systolic)
                TextField("Diastolic (bottom number)", text: $diastolic)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .diastolic)
            }
            
            Section(header: Text("Heart Rate (BPM)")) {
                TextField("Heart Rate", text: $heartRate)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .heartRate)
            }
            
            Section(header: Text("Date & Time")) {
                DatePicker("Select Date", selection: $selectedDate)
                    .focused($focusedField, equals: .date)
            }
            
            Button("Save") {
                if let sys = Double(systolic), let dia = Double(diastolic) {
                    healthStore.saveBloodPressure(systolic: sys, diastolic: dia, date: selectedDate)
                }
                if let bpm = Double(heartRate) {
                    healthStore.saveHeartRate(bpm, date: selectedDate)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    focusedField = nil
                }
            }
        }
    }
}

#Preview {
    let healthStore = HealthStore()
    
    DataEntryView()
        .environmentObject(healthStore)
}
