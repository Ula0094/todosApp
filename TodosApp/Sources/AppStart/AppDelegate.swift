//
//  AppDelegate.swift
//  TodosApp
//
//  Created by Ulugbek Mukhsinovich on 18/09/25.
//

import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        let rootVC = MainModuleBuilder.build()
        
        let nav = UINavigationController(rootViewController: rootVC)
        window.rootViewController = nav
        window.makeKeyAndVisible()
        
        return true
    }
}
