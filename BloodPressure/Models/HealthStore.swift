import Foundation
import HealthKit

class HealthStore: ObservableObject {
    private let healthStore = HKHealthStore()
    @Published var heartRateData: [HKQuantitySample] = []
    @Published var bloodPressureData: [(systolic: HKQuantitySample, diastolic: HKQuantitySample)] = []
    @Published var maxSystolic = Double.leastNormalMagnitude
    @Published var minDiastolic = Double.greatestFiniteMagnitude
    @Published var minHeartRate = Double.greatestFiniteMagnitude
    @Published var maxHeartRate = Double.leastNormalMagnitude
    
    init() {
        requestAuthorization()
    }

    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic)!,
            HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic)!
        ]
        let typesToShare: Set = typesToRead
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { _, _ in }
    }

    func saveHeartRate(_ bpm: Double, date: Date) {
        let type = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let quantity = HKQuantity(unit: HKUnit.count().unitDivided(by: .minute()), doubleValue: bpm)
        let sample = HKQuantitySample(type: type, quantity: quantity, start: date, end: date)
        healthStore.save(sample) { _, _ in }
    }

    func saveBloodPressure(systolic: Double, diastolic: Double, date: Date) {
        let systolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic)!
        let diastolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic)!
        let systolicQuantity = HKQuantity(unit: .millimeterOfMercury(), doubleValue: systolic)
        let diastolicQuantity = HKQuantity(unit: .millimeterOfMercury(), doubleValue: diastolic)

        let systolicSample = HKQuantitySample(type: systolicType, quantity: systolicQuantity, start: date, end: date)
        let diastolicSample = HKQuantitySample(type: diastolicType, quantity: diastolicQuantity, start: date, end: date)

        healthStore.save([systolicSample, diastolicSample]) { _, _ in }
    }

    func fetchData(for period: DateInterval, completion: @escaping () -> Void) {
        //var minHeartRate = Double.greatestFiniteMagnitude
        //var maxHeartRate = Double.leastNormalMagnitude
        var minSystolic = Double.greatestFiniteMagnitude
        //var maxSystolic = Double.leastNormalMagnitude
        //var minDiastolic = Double.greatestFiniteMagnitude
        var maxDiastolic = Double.leastNormalMagnitude
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let systolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic)!
        let diastolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic)!

        let predicate = HKQuery.predicateForSamples(withStart: period.start, end: period.end)

        let heartRateQuery = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
            DispatchQueue.main.async {
                let heartRates = samples as? [HKQuantitySample] ?? []
                self.heartRateData = heartRates
                for sample in heartRates {
                    let value = sample.quantity.doubleValue(for: .init(from: "count/min"))
                    self.minHeartRate = min(self.minHeartRate, value)
                    self.maxHeartRate = max(self.maxHeartRate, value)
                }
                completion()
            }
        }

        let systolicQuery = HKSampleQuery(sampleType: systolicType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, systolicSamples, _ in
            let diastolicQuery = HKSampleQuery(sampleType: diastolicType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, diastolicSamples, _ in
                DispatchQueue.main.async {
                    if let systolics = systolicSamples as? [HKQuantitySample],
                       let diastolics = diastolicSamples as? [HKQuantitySample] {
                        let bpPairs = zip(systolics, diastolics)
                        self.bloodPressureData = bpPairs.map { ($0, $1) }
                        for (sysSample, diaSample) in bpPairs {
                            let sys = sysSample.quantity.doubleValue(for: .millimeterOfMercury())
                            let dia = diaSample.quantity.doubleValue(for: .millimeterOfMercury())
                            minSystolic = min(minSystolic, sys)
                            self.maxSystolic = max(self.maxSystolic, sys)
                            self.minDiastolic = min(self.minDiastolic, dia)
                            maxDiastolic = max(maxDiastolic, dia)
                        }
                        completion()
                    }
                }
            }
            self.healthStore.execute(diastolicQuery)
        }

        healthStore.execute(heartRateQuery)
        healthStore.execute(systolicQuery)
    }

    func meanArterialPressure(systolic: Double, diastolic: Double) -> Double {
        return (2.0 * diastolic + systolic) / 3.0
    }
}
