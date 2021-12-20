//
//  BLEManager.swift
//  MyHydration
//
//  Created by 이민하 on 2021/10/22.
//

import Foundation
import CoreBluetooth
import SwiftUI

extension DataManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            userData.needToSelectModule = true
            startScan()
            print("BLE powered on")
        }
        else if central.state == .poweredOff {
            print("BLE powered off")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Did discover the \(peripheral.name ?? "Unnamed")")
        if userData.needToSelectModule {
            if peripherals.contains(where: { $0.identifier == peripheral.identifier }) {
                return
            } else {
                peripherals.append(peripheral)
            }
        } else {
            if peripheral.identifier == userData.moduleIdentifier {
                centralManager.connect(peripheral, options: nil)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        stopScan()
        isConnected = true
        print("Connected successfully")
        if state == .isReceiving {
            dataLengthBuffer = Data()
            waterIntakesBuffer = Data()
            minuteIntervalsBuffer = Data()
            let module = peripheral
            module.delegate = self
            module.discoverServices([GATT.tumblerModuleServiceUUID])
        }
        else {
            userData.needToSelectModule = false
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        isConnected = false
        print("Fail to connect")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        isConnected = false
        if state == .isReceiving {
            state = .didReceive
        }
        print("Disconnected")
    }
    
    func startScan() {
        centralManager.scanForPeripherals(withServices: [GATT.tumblerModuleServiceUUID], options: nil)
    }
    
    func stopScan() {
        centralManager.stopScan()
    }
    
    func requestData() {
        guard let module = centralManager.retrievePeripherals(withIdentifiers: [userData.moduleIdentifier!]).first else {
            print("No device retrieved")
            userData.needToSelectModule = true
            return
        }
        print("Device was retrieved")
        state = .isReceiving
        centralManager.connect(module, options: nil)
    }
    
    func synchronizeData() {
        DispatchQueue.global(qos: .default).async {
            var dataLength: Int32 = 0
            withUnsafeMutablePointer(to: &dataLength) { pointer in
                let dataLenghtPointer = UnsafeMutableBufferPointer(start: pointer, count: 1)
                self.dataLengthBuffer.copyBytes(to: dataLenghtPointer)
            }
            var waterIntakes: [Int32] = Array(repeating: 0, count: Int(dataLength))
            waterIntakes.withUnsafeMutableBytes { pointer in
                self.waterIntakesBuffer.copyBytes(to: pointer)
            }
            var minuteIntervals: [Int32] = Array(repeating: 0, count: Int(dataLength))
            minuteIntervals.withUnsafeMutableBytes { pointer in
                self.minuteIntervalsBuffer.copyBytes(to: pointer)
            }
            print("data Length : \(dataLength)")
            print("intakes : \(waterIntakes)")
            print("minute intervals : \(minuteIntervals)")
            
            var tempHydrationArray: [Hydration] = []
            var tempHydrationQuantity: Int = 0
            var lastDate = Date()
            self.validateDate(date: lastDate)
            let today = Calendar.current.dateComponents([.year, .month, .day, .weekday], from: lastDate)
            while waterIntakes.last != nil {
                if let intake = waterIntakes.popLast(), let minuteInterval = minuteIntervals.popLast() {
                    let secInterval = TimeInterval(minuteInterval * 60 * -1)
                    lastDate = Date(timeInterval: secInterval, since: lastDate)
                    let lastHydration = Hydration(intake: Int(intake), date: lastDate)
                    if today == lastHydration.dateComponent {
                        tempHydrationQuantity += Int(lastHydration.intake)
                    }
                    tempHydrationArray.insert(lastHydration, at: 0)
                }
            }
            DispatchQueue.main.async {
                self.hydrations.append(contentsOf: tempHydrationArray)
                self.userData.todayHydration += tempHydrationQuantity
            }
            self.state = .noTransfer
        }
    }
}

extension DataManager: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            debugPrint(error)
            return
        }
        guard let services = peripheral.services else {
            debugPrint("Couldn't find any service")
            return
        }
        for service in services {
            if service.uuid == GATT.tumblerModuleServiceUUID {
                print("Discover tumblerModuleService")
                peripheral.discoverCharacteristics([
                    GATT.dataLengthCharacteristicUUID, GATT.notifyReadyCharacteristicUUID,
                    GATT.waterIntakeCharacteristicUUID, GATT.minuteIntervalCharactersiticUUID
                ], for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let receivedData = characteristic.value else {
            print("no data received")
            return
        }
        if characteristic.uuid == GATT.dataLengthCharacteristicUUID {
            dataLengthBuffer.append(receivedData)
            print("Data Length \(dataLengthBuffer.count)")
        }
        else if characteristic.uuid == GATT.waterIntakeCharacteristicUUID {
            waterIntakesBuffer.append(receivedData)
        }
        else if characteristic.uuid == GATT.minuteIntervalCharactersiticUUID {
            minuteIntervalsBuffer.append(receivedData)
            print("Minute Interval \(minuteIntervalsBuffer.count)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            debugPrint(error)
            return
        }
        guard let characteristics = service.characteristics else {
            debugPrint("Couldn't find any characteristics")
            return
        }
        var dataLength: CBCharacteristic?
        var notifyReady: CBCharacteristic?
        for characteristic in characteristics {
            if characteristic.uuid == GATT.dataLengthCharacteristicUUID {
                print("Discover DataLength Charactersitic")
                dataLength = characteristic
            }
            else if characteristic.uuid == GATT.notifyReadyCharacteristicUUID {
                print("Discover notifyReady Charactersitic")
                notifyReady = characteristic
            }
            else if characteristic.uuid == GATT.waterIntakeCharacteristicUUID {
                peripheral.setNotifyValue(true, for: characteristic)
                print("Discover waterIntake Charactersitic")
            }
            else if characteristic.uuid == GATT.minuteIntervalCharactersiticUUID {
                peripheral.setNotifyValue(true, for: characteristic)
                print("Discover minuteInterval Charactersitic")
            }
        }
        guard let dataLength = dataLength, let notifyReady = notifyReady  else {
            return
        }
        peripheral.readValue(for: dataLength)
        peripheral.writeValue(Data([UInt8(1)]), for: notifyReady, type: .withResponse)
    }
}

extension CBPeripheral: Identifiable {
    
}

class GATT {
    static let tumblerModuleServiceUUID = CBUUID(string: "1101")
    static let dataLengthCharacteristicUUID = CBUUID(string: "2101")
    static let notifyReadyCharacteristicUUID = CBUUID(string: "2102")
    static let waterIntakeCharacteristicUUID = CBUUID(string: "2104")
    static let minuteIntervalCharactersiticUUID = CBUUID(string: "2108")
}

extension DataManager {
    enum TransferState {
        case noTransfer
        case isReceiving
        case didReceive
    }
}
