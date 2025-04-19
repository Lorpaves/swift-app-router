//
//  ExampleApp.swift
//  Example
//
//  Created by Lorpaves on 2025/4/19.
//

import SwiftUI
import Router

@main
struct ExampleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.openURL, OpenURLAction { url in
                    // Do something here...
                    Task {
                        print("Open url: \(url)")
                        try await AppRouter.shared.open(url: url)
                    }
                    return .handled
                })
        }
    }
}
