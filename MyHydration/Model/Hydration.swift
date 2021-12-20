//
//  Hydration.swift
//  MyHydration
//
//  Created by 이민하 on 2021/11/02.
//

import Foundation
import HealthKit

struct Hydration: Identifiable, Codable {
    let intake: Double
    var date: Date
    let id: UUID
    
    var dateComponent: DateComponents {
        let calendar = Calendar.current
        return calendar.dateComponents([.year, .month, .day, .weekday], from: self.date)
    }
    
    init() {
        self.intake = 150
        self.id = UUID()
        self.date = Date()
    }
    
    init(intake: Double) {
        self.intake = intake
        self.id = UUID()
        self.date = Date()
    }
    
    init(intake: Int, date: Date) {
        self.intake = Double(intake)
        self.id = UUID()
        self.date = date
    }
    
    static func allHydration() -> [Hydration] {
        var hydrations = [Hydration]()
        
        let now = Date()
        var intervalSum: TimeInterval = 24 * 60 * 60 * -1
        for _ in 0..<2000 {
            let intake = Int.random(in: 50...100)
            let timeInterval = TimeInterval(Int.random(in: 60...360) * 60 * -1)
            intervalSum += timeInterval
            let date = Date(timeInterval: intervalSum, since: now)
            let newHydration = Hydration(intake: intake, date: date)
            hydrations.append(newHydration)
        }
        
        return hydrations
    }
}

struct IntakeRecord: Codable {
    let date: Date
    let quantity: Int
    
    init(quantity: Int) {
        self.date = Date()
        self.quantity = quantity
    }
}

struct DailyHydration: Codable {
    let startDate: Date
    let endDate: Date
    var intakes: [IntakeRecord] = []
    var totalIntake: Int = 0
    var goalIsAchieved: Bool = false
    
    init(of today: Date) {
        let calendar = Calendar.current
        let dateInterval = calendar.dateInterval(of: .day, for: today)
        self.startDate = dateInterval!.start
        self.endDate = dateInterval!.end
    }
}
