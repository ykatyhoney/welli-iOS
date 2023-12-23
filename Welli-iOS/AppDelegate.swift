//
//  AppDelegate.swift
//  Welli-iOS
//
//  Created by Raul Cheng on 7/11/23.
//

import UIKit
import WatchConnectivity

//@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // Request user notifications authorization
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Failed to request authorization for user notifications: \(error.localizedDescription)")
                return
            }
            if granted {
                print("User notifications authorized.")
            } else {
                print("User notifications not authorized.")
            }
        }
        
        return true
    }
}
