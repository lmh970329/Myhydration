//
//  MyHydrationApp.swift
//  MyHydration
//
//  Created by 이민하 on 2021/09/27.
//

import SwiftUI
import UserNotifications

@main
struct MyHydrationApp: App {
    
    @ObservedObject var dataManager = DataManager()
    init() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = dataManager
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { grated, error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        dataManager.load()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView() {
                dataManager.save()
            }
                .environment(\.locale, Locale(identifier: "ko"))
                .environmentObject(dataManager)
        }
    }
}
