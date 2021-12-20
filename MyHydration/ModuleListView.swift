//
//  ModuleListView.swift
//  MyHydration
//
//  Created by 이민하 on 2021/10/22.
//

import SwiftUI
import CoreBluetooth

struct ModuleListView: View {
    @EnvironmentObject var dataManager: DataManager
    @Binding var peripherals: [CBPeripheral]
    var body: some View {
        List {
            ForEach(peripherals, id: \.self) { peripheral in
                Button(peripheral.name ?? "") {
                    dataManager.userData.moduleIdentifier = peripheral.identifier
                    if dataManager.userData.needUserData {
                        dataManager.userData.needUserData = false
                    }
                }
            }
        }
    }
}

struct ModuleListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ModuleListView(peripherals: .constant([])).environmentObject(DataManager())
        }
    }
}
