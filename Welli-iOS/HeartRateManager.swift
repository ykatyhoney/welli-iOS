//
//  HeartRateManager.swift
//  Welli-iOS
//
//  Created by Raul Cheng on 1/17/24.
//

import HealthKit
import Combine

final class HeartRateManager {

    private var healthStore: HKHealthStore
    private let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)
    private var highHeartRateSubject = PassthroughSubject<Void, Never>()
    var highHeartRatePublisher: AnyPublisher<Void, Never> {
        highHeartRateSubject.eraseToAnyPublisher()
    }

    init(healthStore: HKHealthStore = HKHealthStore()) {
        self.healthStore = healthStore
    }

    func requestAuthorization() async throws {
        guard let heartRateType else {
            return
        }
        try await healthStore.requestAuthorization(toShare: Set(), read: [heartRateType])
    }

    func startObservation() {
        guard let heartRateType else {
            return
        }
        let query = HKObserverQuery(sampleType: heartRateType, predicate: nil) { [weak self] query, completion, error in
            self?.fetchLastItem()
        }
        healthStore.enableBackgroundDelivery(for: heartRateType, frequency: .immediate) { _, _ in }
        healthStore.execute(query)
    }

    private func fetchLastItem() {
        guard let heartRateType else {
            return
        }

        let sort = [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        let query = HKSampleQuery(
            sampleType: heartRateType,
            predicate: nil,
            limit: 1, sortDescriptors: sort
        ) { [weak self] query, samples, error in

            guard let samples = samples as? [HKQuantitySample], error == nil else {
                return
            }

            if samples.first(where: {
                $0.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute())) > 70
            }) != nil {
                DispatchQueue.main.async {
                    self?.highHeartRateSubject.send()
                }
            }
        }

        healthStore.execute(query)
    }
}

