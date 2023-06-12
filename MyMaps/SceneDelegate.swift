//
//  SceneDelegate.swift
//  MyMaps
//
//  
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    var visualEffectView = UIVisualEffectView()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        
        window?.rootViewController = Launch()
        window?.makeKeyAndVisible()
        
        NotificationService.shared.requestAuthorization()
    }

    func sceneDidDisconnect(_ scene: UIScene) { }

    func sceneDidBecomeActive(_ scene: UIScene) {
        removeBlurView()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        addBlurView()
        setupNotificationService()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        removeBlurView()
    }

    func sceneDidEnterBackground(_ scene: UIScene) { }
    
    private func addBlurView() {
        if !self.visualEffectView.isDescendant(of: self.window!) {
            self.window?.addSubview(self.visualEffectView)
        }
        self.visualEffectView.frame = (self.window?.bounds)!

        UIView.animate(withDuration: 0.5) {
            self.visualEffectView.effect = UIBlurEffect(style: .light)
        }
    }
    
    private func removeBlurView() {
        self.visualEffectView.effect = nil
        self.visualEffectView.removeFromSuperview()
    }
    
    private func setupNotificationService() {
        let notificationService = NotificationService.shared
        
        notificationService.checkNotificationAuthorization { settings in
            switch settings.authorizationStatus {
            case .authorized:
                notificationService
                    .sendNotificatoinRequest(content: notificationService.makeNotificationContent(),
                                             trigger: notificationService.makeIntervalNotificationTrigger(time: (30 * 60)))
            case .denied:
                print("not allowed")
            case .notDetermined:
                print("incomprehensibly")
            default:
                print("default")
            }
        }
    }
}

