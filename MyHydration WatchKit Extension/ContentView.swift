//
//  ContentView.swift
//  MyHydration WatchKit Extension
//
//  Created by 이민하 on 2021/09/27.
//

import SwiftUI

struct ContentView: View {
    let saveAction: () -> Void
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        TrackerRingView(dailyGoal: dataManager.userData.dailyGoal ?? 1800, currentHydration: 1000)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(saveAction: {}).environmentObject(DataManager())
    }
}
