//
//  Chat_ApplicationApp.swift
//  Chat Application
//
//  Created by Yogesh Rao on 28/05/23.
//  Copyright © 2023 Yogesh Rao. All rights reserved.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct Chat_ApplicationApp: App {
    //Registering AppDelegate for Firebase configuration
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
