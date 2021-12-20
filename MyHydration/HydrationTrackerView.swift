//
//  HydrationTrackerView.swift
//  MyHydration
//
//  Created by 이민하 on 2021/09/27.
//

import SwiftUI

struct HydrationTrackerView: View {

    @Environment(\.scenePhase) private var scenePhase
    
    @EnvironmentObject var dataManager: DataManager
    
    @State private var showAlarmAddView = false
    @State private var showAlarmEditView = false
    @State private var showHydrationEditView = false
    
    @State private var newHydration: Double = 0
    
    private let myBlue = Color(red: 104/255, green: 150/255, blue: 203/255)
    
    var body: some View {
        NavigationView {
            List {
                TrackerRingView(dailyGoal: dataManager.userData.dailyGoal ?? 1800, currentHydration: dataManager.userData.todayHydration)
                    .padding(5)
                    .listRowSeparator(.hidden)
                
                Section(header: HStack {
                    Text("수분 섭취 알림").font(.headline)
                    
                    Spacer()
                    
                    Button(action: { showAlarmAddView = true }) {
                        Image(systemName: "plus")
                    }.sheet(isPresented: $showAlarmAddView) {
                        AlarmAddView(alarms: $dataManager.alarms, isPresented: $showAlarmAddView)
                    }
                }) {
                    if dataManager.alarms.isEmpty {
                        Text("설정된 알람이 없습니다.").font(.title)
                            .listRowSeparator(.hidden)
                            .listStyle(.inset)
                    }
                    else {
                        ForEach(dataManager.alarms) { alarm in
                            AlarmRow(alarm: binding(for: alarm))
                        }.onDelete {
                            dataManager.deleteAlarm(at: $0)
                        }
                    }
                }
            }
            .listStyle(InsetListStyle())
            .padding(0)
            .navigationTitle("수분 섭취 링")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showHydrationEditView = true
                    }) {
                        Label("추가", systemImage: "drop.fill").labelStyle(.titleOnly).font(.headline)
                    }.sheet(isPresented: $showHydrationEditView) {
                        HydrationEditView(showHydrationEditView: $showHydrationEditView, newHydration: $newHydration, currentHydration: $dataManager.userData.todayHydration, presets: $dataManager.userData.userPreset, hydrations: $dataManager.hydrations)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    
                    if dataManager.isConnected {
                        ProgressView().progressViewStyle(.circular)
                    }
                    else {
                        Button(action: {
                            withAnimation {
                                if !dataManager.isConnected {
                                    dataManager.requestData()
                                }
                            }
                        }) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                        }
                    }
                }
            }
        }
        .refreshable {
            if !dataManager.isConnected {
                dataManager.requestData()
            }
        }
    }
    
    func binding(for alarm: Alarm) -> Binding<Alarm> {
        guard let alarmIndex = dataManager.alarms.firstIndex(where: { $0.id.uuidString == alarm.id.uuidString }) else {
            fatalError("Can't find alarm in array")
        }
        return $dataManager.alarms[alarmIndex]
    }
}

struct HydrationTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        HydrationTrackerView().environmentObject(DataManager())
    }
}
