import WatchKit
import UserNotifications
import WatchConnectivity

class ExtensionDelegate: NSObject, WKApplicationDelegate, WCSessionDelegate {
    
    let session = WCSession.default
    
    func applicationDidFinishLaunching() {
        if WCSession.isSupported() {
            //let session = WCSession.default
            session.delegate = self
            do {
                try session.activate()
            } catch {
                print("Failed to activate WCSession: \(error.localizedDescription)")
            }
        }
        
        HeartRateMonitor.shared.startMonitoringHeartRate()
        
        //MARK: Schedule Notification
        scheduleDailyNotifications()
    }
    
    // The workout session will now continue when the app goes into the background
    func applicationWillResignActive() {
        // Do not stop monitoring when app goes to background
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed with error: \(error.localizedDescription)")
            return
        }
        print("WCSession (watch) activation completed with state: \(activationState.rawValue)")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let heartRate = message["heartRate"] as? Double {
            print("Received heart rate: \(heartRate) bpm")
            HeartRateMonitor.shared.sendHeartRateDataToPhone(heartRate)
        }
    }
    
    //MARK: to make session consistent
    func applicationWillEnterForeground() {
//        if WCSession.default.activationState == .activated {
//            // Your session is already activated, resume communication.
//        } else {
//            // Activate the session if it's not already activated.
//            WCSession.default.activate()
//        }
    }
    
    func applicationDidBecomeActive() {
        
        if session.activationState == .activated {
            // Your session is already activated, resume communication.
        } else {
            // Activate the session if it's not already activated.
            do {
                try session.activate()
            } catch {
                print("Failed to activate WCSession: \(error.localizedDescription)")
            }
        }
    }
    
    //MARK: Schedule Notification

    func scheduleDailyNotifications() {
        // Cancel All pending notifications
        cancelAllNotifications()
        
        let notificationTimes = ["12:00 PM", "3:00 PM", "6:00 PM", "8:00 PM"]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        for timeString in notificationTimes {
            guard let date = dateFormatter.date(from: timeString) else { continue }
            
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: date)
            
            var notification = UNMutableNotificationContent()
            notification.title = "Daily Reminder"
            notification.body = "please check in"
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: notification, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                } else {
                    print("Notification scheduled successfully!")
                }
            }
        }
    }
    
    func cancelAllNotifications() {
            let center = UNUserNotificationCenter.current()
            
            // Remove all pending notification requests
            center.removeAllPendingNotificationRequests()
        }
    
}

