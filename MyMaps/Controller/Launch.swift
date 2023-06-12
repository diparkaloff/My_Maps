//
//  Launch.swift
//  MyMaps
//
//  
//

import UIKit

class Launch: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.whiteColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if UserDefaults.standard.bool(forKey: "isLogin") {
            let toVC = MainViewController()
            toVC.modalTransitionStyle = .crossDissolve
            toVC.modalPresentationStyle = .fullScreen
            present(toVC, animated: true, completion: nil)
        } else {
            let toVC = LoginViewController()
            let navigationVC = UINavigationController(rootViewController: toVC)
            navigationVC.modalTransitionStyle = .crossDissolve
            navigationVC.modalPresentationStyle = .fullScreen
            present(navigationVC, animated: true, completion: nil)
        }
    }
}
