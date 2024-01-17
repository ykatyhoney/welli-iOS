//
//  NotificationScheduler.swift
//  Welli-iOS
//
//  Created by Raul Cheng on 1/17/24.
//

import Foundation
import UserNotifications

final class NotificationScheduler {

    private var notificationCenter: UNUserNotificationCenter

    init(notificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current()) {
        self.notificationCenter = notificationCenter
    }

    func scheduleHeartRateNotification() {
        let content = UNMutableNotificationContent()
        content.title = "High Heart Rate"
        content.body = "Your heart rate is above 70 bpm."
        content.sound = UNNotificationSound.default

        let request = UNNotificationRequest(identifier: "HighHeartRate", content: content, trigger: nil)
        notificationCenter.add(request) { error in
            if let error {
                print(error)
            }
        }
    }
}
