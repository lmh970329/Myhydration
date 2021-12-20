//
//  ContentView.swift
//  MyHydration
//
//  Created by 이민하 on 2021/09/27.
//

import SwiftUI



struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    
    @EnvironmentObject var dataManager: DataManager

    @State private var tab: Tab = .track
    @State var data : UserData.Data = UserData.Data(userName: "", dailyGoal: 1800)
    
    
    
    enum Tab {
        case track
        case activity
        case user
    }
    
    let saveAction: () -> Void
    
    var body: some View {
        TabView(selection: $tab) {
            HydrationTrackerView().environmentObject(dataManager)
                .tabItem {
                    Label("Track", systemImage: "drop.fill")
                }.tag(Tab.track)
            /*
                .sheet(isPresented: $dataManager.userData.needToSelectModule) {
                    NavigationView {
                        ModuleListView(peripherals: $dataManager.peripherals)
                    }
                }
            */
            HydrationActivityView(hydrations: $dataManager.hydrations).tabItem {
                Label("Activitiy", systemImage: "chart.bar.fill")
            }.tag(Tab.activity)
            UserInformationView(userData: $dataManager.userData).tabItem {
                Label("User", systemImage: "person.fill")
            }.tag(Tab.user)
        }.fullScreenCover(isPresented: $dataManager.userData.needUserData) {
            NavigationView {
                UserInformationEditView(userData: $data)
                    .navigationTitle("사용자 정보 입력")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            NavigationLink(destination: {
                                ModuleListView(peripherals: $dataManager.peripherals).environmentObject(dataManager)
                                    .onAppear {
                                        print("appear")
                                        dataManager.updateUserData(from: data)
                                        dataManager.startScan()
                                    }
                                    .onDisappear {
                                        print("disappear")
                                        if dataManager.centralManager.isScanning {
                                            dataManager.stopScan()
                                        }
                                    }
                            }) {
                                Label("다음", systemImage: "chevron.right")
                                    .labelStyle(.titleOnly)
                            }.disabled(data.userName == "")
                        }
                    }
            }
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                print("scenePhase is active")
                dataManager.updateAlarmActivationStatus()
                dataManager.validateDate(date: Date())
            } else if phase == .inactive {
                print("scenPhase is inactive")
                saveAction()
            }
        }
        .tabViewStyle(DefaultTabViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(saveAction: {}).environmentObject(DataManager())
    }
}
