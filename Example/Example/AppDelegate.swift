//
//  AppDelegate.swift
//  Example
//
//  Created by Lorpaves on 2025/4/19.
//

import Router
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        AppRouter.shared.register("example://open/userInfo", factory: { route, _ in
            if let type = route.parameters["type"] {
                if type == "modal"{
                    return (UIViewController.make(route: route), .modal)
                }
                if type == "push" {
                    return (UIViewController.make(route: route), .push)
                }
            }
            return nil 
            
        })
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        Task {
            try await AppRouter.shared.open(url: url)
        }
        return false
    }
}

private extension UIViewController {
    static func make(route: any Route) -> UIViewController {
        UIHostingController(
            rootView:
            Form {
                Section("URL:") {
                    Text(route.url.absoluteString)
                }
                
                Section("Parameters:") {
                    ForEach(Array(zip(route.parameters.keys, route.parameters.values)), id: \.0) { (key, value) in
                        HStack {
                            Text(key)
                            Spacer()
                            Text(value)
                        }
                    }
                }
            }
        )
    }
}
