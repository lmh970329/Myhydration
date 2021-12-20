//
//  UserData.swift
//  MyHydration
//
//  Created by 이민하 on 2021/10/20.
//

import Foundation
import SwiftUI

struct UserData: Codable {
    var userName: String?
    var dailyGoal: Int?
    var moduleIdentifier: UUID?
    var userPreset = [Int]()
    var needUserData: Bool = true
    var needToSelectModule: Bool = true
    var todayHydration: Int = 0
    var userActivity = Activity()
}

extension UserData {
    struct Activity: Codable {
        enum Achievement: Codable {
            case forWeek
            case forMonth
            case forYear
        }
        var consecutiveDailyGoalAchievement: Int = 0
        var record: [Achievement] = []
    }
    
    struct Data {
        var userName: String
        var dailyGoal: Double
    }
    
    var data: Data {
        return Data(userName: userName ?? "", dailyGoal: Double(dailyGoal ?? 0))
    }
}

extension DataManager {
    func updateUserData(from data: UserData.Data) {
        userData.userName = data.userName
        userData.dailyGoal = Int(data.dailyGoal)
    }
}
