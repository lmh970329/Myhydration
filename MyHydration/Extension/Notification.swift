//
//  DataManager.swift
//  MyHydration
//
//  Created by 이민하 on 2021/11/02.
//

import Foundation
import SwiftUI
import UserNotifications
import CoreBluetooth

extension DataManager: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Did response")
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            if response.notification.request.trigger?.repeats == false {
                guard let idx = alarms.firstIndex(where: { alarm in
                    alarm.isBelongingIdentifier(response.notification.request.identifier)
                }) else { return }
                alarms[idx].isActivated = false
            }
        }
    }
    
    func addAlarm(at date: Date, on weekDays: [WeekDay]) {
        let newAlarm = Alarm(date: date, weekDays: weekDays)
        alarms.append(newAlarm)
    }
    
    func deleteAlarm(at ids: IndexSet) {
        for idx in ids {
            self.alarms[idx].isActivated = false
            self.alarms.remove(at: idx)
        }
    }
    
    func updateAlarmActivationStatus() {
        DispatchQueue.global(qos: .background).async {
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.getPendingNotificationRequests { requests in
                let requestIdentifiers = requests.map { $0.identifier }
                for alarm in self.alarms {
                    if !alarm.isRepeatEnabled && alarm.isActivated {
                        if requestIdentifiers.contains(alarm.getFirstIdentifiers()!) == false {
                            let idx = self.alarms.firstIndex(where: { $0.id == alarm.id })
                            DispatchQueue.main.async {
                                self.alarms[idx!].isActivated = false
                            }
                        }
                    }
                }
            }
        }
    }
}

extension UNNotificationRequest {
    func isBelongedTo(alarm: Alarm) -> Bool {
        return alarm.isBelongingIdentifier(self.identifier)
    }
}
