//
//  LocationManager.swift
//  MyMaps
//
//  
//

import Foundation
import UserNotifications

class NotificationService {
    
    static var shared = NotificationService()
    
    private let center = UNUserNotificationCenter.current()
    
    private init() {}
    
    func makeNotificationContent(title: String = "hello",
                                 subtitle: String = "it's time to see where you are",
                                 body: String = "will you take a look ?",
                                 badge: NSNumber = 1) -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        content.badge = badge
        return content
    }
    
    func makeIntervalNotificationTrigger(time: TimeInterval,
                                         repeats: Bool = false) -> UNNotificationTrigger {
        return UNTimeIntervalNotificationTrigger(timeInterval: time,
                                                 repeats: repeats)
    }
    
    func sendNotificatoinRequest(content: UNNotificationContent,
                                 trigger: UNNotificationTrigger) {
        let request = UNNotificationRequest(identifier: "alarm",
                                            content: content,
                                            trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        center.add(request) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            guard granted else {
                print("not allowed")
                return
            }
        }
    }
    
    func checkNotificationAuthorization(complitionHandler: @escaping (UNNotificationSettings) -> ()) {
        center.getNotificationSettings { settings in
            complitionHandler(settings)
        }
    }
}
