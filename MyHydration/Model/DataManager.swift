//
//  DataManager.swift
//  MyHydration
//
//  Created by 이민하 on 2021/11/05.
//

import Foundation
import CoreBluetooth

class DataManager: NSObject, ObservableObject {
    
    @Published var alarms = [Alarm]()
    @Published var userData = UserData()
    @Published var hydrations = [Hydration]()
    @Published var peripherals: [CBPeripheral]!
    @Published var isConnected: Bool = false
    
    var centralManager: CBCentralManager!
    var dataLengthBuffer: Data = Data()
    var waterIntakesBuffer: Data = Data()
    var minuteIntervalsBuffer: Data = Data()
    var state: TransferState = .noTransfer {
        didSet {
            if state == .didReceive {
                synchronizeData()
            }
        }
    }
    private var lastOperateDate: Date!
    
    override init() {
        super.init()
        centralManager = CBCentralManager()
        centralManager.delegate = self
        peripherals = []
        lastOperateDate = Date()
    }
    
    func validateDate(date: Date) {
        let calendar = Calendar.current
        let lastOperateDay = calendar.dateInterval(of: .day, for: lastOperateDate)?.start
        let currentDay = calendar.dateInterval(of: .day, for: date)?.start
        if lastOperateDay != currentDay {
            userData.todayHydration = 0
        }
        self.lastOperateDate = date
    }
    
    func updateDailyData() {
        
    }
    
    private static var documentsFolder: URL {
        do {
            return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        } catch {
            fatalError("Can't find documents directory")
        }
    }
    private static var alarmFileURL: URL {
        return documentsFolder.appendingPathComponent("alarms.data")
    }
    private static var hydrationFileURL: URL {
        return documentsFolder.appendingPathComponent("hydrations.data")
    }
    private static var userFileURL: URL {
        return documentsFolder.appendingPathComponent("user.data")
    }
    
    func load() {
            guard let alarmData = try? Data(contentsOf: Self.alarmFileURL) else { return }
            guard let hydrationData = try? Data(contentsOf: Self.hydrationFileURL) else { return }
            guard let userData = try? Data(contentsOf: Self.userFileURL) else { return }
            
            guard let alarms = try? JSONDecoder().decode([Alarm].self, from: alarmData) else {
                fatalError("Can't decode saved alarm data.")
            }
            guard let hydrations = try? JSONDecoder().decode([Hydration].self, from: hydrationData) else {
                fatalError("Can't decode saved hydration data")
            }
            guard let userData = try? JSONDecoder().decode(UserData.self, from: userData) else {
                fatalError("Can't decode saved user data")
            }
                self.alarms = alarms
                self.userData = userData
                self.hydrations = hydrations
    }
    
    func save() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let alarms = self?.alarms else { fatalError("Self out of scope") }
            guard let hydrations = self?.hydrations else { fatalError("Self out of scope") }
            guard let userData = self?.userData else { fatalError("Self out of scope") }
            
            guard let alarmData = try? JSONEncoder().encode(alarms) else { fatalError("Error encoding alarm data") }
            guard let hydrationData = try? JSONEncoder().encode(hydrations) else { fatalError("Error encoding hydration data") }
            guard let user = try? JSONEncoder().encode(userData) else { fatalError("Error encoding user data") }
            
            do {
                let alarmOutfile = Self.alarmFileURL
                try alarmData.write(to: alarmOutfile)
            } catch {
                fatalError("Can't write alarm to file")
            }
            do {
                let hydrationOutfile = Self.hydrationFileURL
                try hydrationData.write(to: hydrationOutfile)
            } catch {
                fatalError("Can't write hydration to file")
            }
            do {
                let userOutfile = Self.userFileURL
                try user.write(to: userOutfile)
            } catch {
                fatalError("Can't write user data to file")
            }
        }
    }
}
