//
//  AlarmEditView.swift
//  MyHydration
//
//  Created by 이민하 on 2021/09/29.
//

import SwiftUI

struct AlarmEditView: View {
    @Binding var alarmData: Alarm.Data
    @Binding var isPresented: Bool
    @EnvironmentObject var dataManager: DataManager
    
    var alarm: Alarm
    
    var body: some View {
        Form {
            DatePicker(selection: $alarmData.date, displayedComponents: [.hourAndMinute], label: {})
                .labelsHidden()
                .datePickerStyle(WheelDatePickerStyle())
            
            Section() {
                NavigationLink { DayRepeatSelectionView(weekDays: $alarmData.weekDays)
                        .navigationTitle("반복")
                        .navigationBarTitleDisplayMode(.inline)
                } label: {
                    HStack {
                        Text("반복")
                        Spacer()
                        Text(repeatDescription(weekDays: alarmData.weekDays)).foregroundColor(.gray)
                    }
                }
            }
            
            Button("알람 삭제", role: .destructive, action: {
                if let alarmIndex = dataManager.alarms.firstIndex(where: { $0.id == alarm.id}) {
                    dataManager.deleteAlarm(at: [alarmIndex])
                } else {
                    print("Can't find such alarm")
                }
                isPresented = false
            }).frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

struct AlarmEditView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmEditView(alarmData: .constant(Alarm.Data()), isPresented: .constant(true), alarm: Alarm(date: Date(), weekDays: [])).environmentObject(DataManager())
    }
}
