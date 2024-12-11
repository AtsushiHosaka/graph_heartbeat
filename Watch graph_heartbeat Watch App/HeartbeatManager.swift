//
//  HeartbeatManager.swift
//  Watch graph_heartbeat Watch App
//
//  Created by 保坂篤志 on 2023/06/19.
//

import Foundation
import HealthKit
import WatchConnectivity

class HeartbeatManager: NSObject, ObservableObject {
    
    var connectionSession: WCSession
    
    init(connectionSession: WCSession = .default) {
        
        self.connectionSession = connectionSession
        super.init()
        self.connectionSession.delegate = self
        connectionSession.activate()
    }
    
    static let shared = HeartbeatManager()

    @Published var showingSummaryView: Bool = false {
        didSet {
            if showingSummaryView == false {
                resetWorkout()
            }
        }
    }

    let healthStore = HKHealthStore()
    var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?

    func startWorkout() {
        let configuration = HKWorkoutConfiguration()
        // 必要なactivityTypeを設定
        configuration.activityType = .other
        configuration.locationType = .indoor

        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session?.associatedWorkoutBuilder()
        } catch {
            return
        }

        session?.delegate = self
        builder?.delegate = self

        builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore,
                                                      workoutConfiguration: configuration)

        let startDate = Date()
        session?.startActivity(with: startDate)
        builder?.beginCollection(withStart: startDate) { (success, error) in
            // The workout has started.
        }
    }

    func requestAuthorization() {
        let typesToShare: Set = [
            HKQuantityType.workoutType()
        ]

        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!
        ]

        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
            // Handle error.
        }
    }

    @Published var running = false

    func togglePause() {
        if running == true {
            self.pause()
        } else {
            resume()
        }
    }

    func pause() {
        session?.pause()
    }

    func resume() {
        session?.resume()
    }

    func endWorkout() {
        session?.end()
        showingSummaryView = true
    }

    @Published var averageHeartRate: Double = 0 {
        didSet {
            sendMessage()
        }
    }
    @Published var heartRate: Double = 0
    @Published var workout: HKWorkout?

    func updateForStatistics(_ statistics: HKStatistics?) {
        guard let statistics = statistics else { return }

        DispatchQueue.main.async {
            switch statistics.quantityType {
            case HKQuantityType.quantityType(forIdentifier: .heartRate):
                let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                self.heartRate = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) ?? 0
                self.averageHeartRate = statistics.averageQuantity()?.doubleValue(for: heartRateUnit) ?? 0
            default:
                return
            }
        }
    }

    func resetWorkout() {
        builder = nil
        workout = nil
        session = nil
        averageHeartRate = 0
        heartRate = 0
    }
    
    func sendMessage() {
        let messages: [String: Any] = ["heartbeat": heartRate]
        
        connectionSession.sendMessage(messages, replyHandler: nil) { (error) in
            print(error.localizedDescription)
        }
    }
}

extension HeartbeatManager: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState,
                        from fromState: HKWorkoutSessionState, date: Date) {
        DispatchQueue.main.async {
            self.running = toState == .running
        }

        if toState == .ended {
            builder?.endCollection(withEnd: date) { (success, error) in
                self.builder?.finishWorkout { (workout, error) in
                    DispatchQueue.main.async {
                        self.workout = workout
                    }
                }
            }
        }
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        
    }
}

extension HeartbeatManager: HKLiveWorkoutBuilderDelegate {
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {

    }

    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else {
                return
            }

            let statistics = workoutBuilder.statistics(for: quantityType)
            updateForStatistics(statistics)
        }
    }
}

extension HeartbeatManager: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        } else {
            print("The session has completed activation.")
        }
    }
}
