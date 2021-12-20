//
//  Alarm.swift
//  MyHydration
//
//  Created by 이민하 on 2021/09/28.
//

import Foundation
import UserNotifications
import SwiftUI

struct Alarm: Identifiable, Codable {
    
    private var requestedIdentifiers = [String]()
    
    let id: UUID
    var date: Date
    var weekDays: [WeekDay]
    var isActivated: Bool {
        didSet {
            if isActivated {
                print("Alarm has been activated")
                self.requestNotifications()
            } else {
                print("Alarm has been deactivated")
                self.cancelAllNotifications()
            }
        }
    }
    var isRepeatEnabled: Bool {
        return !weekDays.isEmpty
    }
    
    init(id: UUID = UUID(), date: Date, weekDays: [WeekDay], isActivated: Bool = false) {
        self.id = id
        self.date = date
        self.weekDays = weekDays
        self.isActivated = isActivated
    }
    
    mutating func update(from data: Data) {
        cancelAllNotifications()
        date = data.date
        weekDays = data.weekDays
        isActivated = true
    }
    
    mutating func requestNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { settings in
            guard (settings.authorizationStatus == .authorized) || (settings.authorizationStatus == .provisional)
            else {
                return
            }
        }
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: self.date)
        let minute = calendar.component(.minute, from: self.date)
        
        var dateComponent = DateComponents(hour: hour, minute: minute)
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = NSString.localizedUserNotificationString(forKey: "물 마실 시간입니다!", arguments: nil)
        notificationContent.body = NSString.localizedUserNotificationString(forKey: "일일 목표 달성을 위해 충분한 수분을 섭취해주세요.", arguments: nil)
        notificationContent.sound = .default
        
        if !isRepeatEnabled {
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
            printNextTriggerDate(trigger)
            let requestIdentfier = UUID().uuidString
            requestedIdentifiers.append(requestIdentfier)
            let request = UNNotificationRequest(identifier: requestIdentfier, content: notificationContent, trigger: trigger)
            
            notificationCenter.add(request) { error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        } else {
            for weekDay in weekDays {
                dateComponent.weekday = weekDay.rawValue
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: true)
                printNextTriggerDate(trigger)
                let requestIdentifier = UUID().uuidString
                requestedIdentifiers.append(requestIdentifier)
                let request = UNNotificationRequest(identifier: requestIdentifier, content: notificationContent, trigger: trigger)
                
                notificationCenter.add(request) { error in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    mutating func cancelAllNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removePendingNotificationRequests(withIdentifiers: requestedIdentifiers)
        requestedIdentifiers.removeAll()
    }
    
    func isBelongingIdentifier(_ id: String) -> Bool {
        return requestedIdentifiers.contains(id)
    }
    
    func getFirstIdentifiers() -> String? {
        return self.requestedIdentifiers.first
    }
}

enum WeekDay: Int, CaseIterable, Identifiable, Comparable, Codable {
    
    var id: Self { self }
    
    case sun = 1, mon, tue, wed, thu, fri, sat
    
    func toString() -> String {
        switch self {
        case .sun:
            return "일"
        case .mon:
            return "월"
        case .tue:
            return "화"
        case .wed:
            return "수"
        case .thu:
            return "목"
        case .fri:
            return "금"
        case .sat:
            return "토"
        }
    }
    
    static func < (lhs: WeekDay, rhs: WeekDay) -> Bool {
        if lhs.rawValue < rhs.rawValue {
            return true
        } else {
            return false
        }
    }
}

extension Alarm {
    struct Data {
        var date : Date = Date()
        var weekDays: [WeekDay] = []
    }
    
    var data: Data {
        return Data(date: date, weekDays: weekDays)
    }
}

/****************************  helper functions ********************************/

func repeatDescription(weekDays: [WeekDay]) -> String {
    var description = String()
    
    if weekDays.isEmpty {
        description = "반복 안 함"
    } else if weekDays.count == 7 {
        description = "매일"
    } else if weekDays == [.mon, .tue, .wed, .thu, .fri] {
        description = "주중"
    } else if weekDays == [.sun, .sat] {
        description = "주말"
    } else {
        let dayList = weekDays.map { $0.toString() }
        description = dayList.joined(separator: " ")
    }
    return description
}

func formatDate(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "ko_KR")
    dateFormatter.dateStyle = .none
    dateFormatter.timeStyle = .short
    
    return dateFormatter.string(from: date)
}

func printNextTriggerDate(_ trigger: UNCalendarNotificationTrigger) {
    if let nextDate = trigger.nextTriggerDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .short
        print(dateFormatter.string(from: nextDate))
    } else {
        print("Next date doesn't exist.")
    }
}
