//
//  AlarmAddView.swift
//  MyHydration
//
//  Created by 이민하 on 2021/10/07.
//

import SwiftUI

struct AlarmAddView: View {
    
    @Binding var alarms: [Alarm]
    @Binding var isPresented: Bool
    
    @State private var newAlarm: Alarm = Alarm(date: Date(), weekDays: [])
    
    var body: some View {
        NavigationView {
            List {
                DatePicker(selection: $newAlarm.date, displayedComponents: [.hourAndMinute],label: {})
                    .labelsHidden()
                    .datePickerStyle(WheelDatePickerStyle())
                Section() {
                    NavigationLink {
                        DayRepeatSelectionView(weekDays: $newAlarm.weekDays)
                            .navigationBarTitle("반복")
                            .listStyle(InsetGroupedListStyle())
                    } label: {
                        HStack {
                            Text("반복").font(.body).foregroundColor(.black)
                            Spacer()
                            Text(repeatDescription(weekDays: newAlarm.weekDays)).foregroundColor(.gray).font(.body)
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("알람 추가")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("취소", role: .cancel, action: {
                    isPresented.toggle()
                }).font(.headline),
                trailing: Button("저장", action: {
                    newAlarm.isActivated = true
                    addAlarm(alarm: newAlarm)
                    print("\(newAlarm.id) has been added.")
                    for alarm in alarms {
                        print("\(alarm.id)")
                    }
                    isPresented.toggle()
            }).font(.headline))
        }
    }
    
    func addAlarm(alarm: Alarm) {
        alarms.append(alarm)
    }
}

struct AlarmAddView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmAddView(alarms: .constant([Alarm]()),isPresented: .constant(true))
    }
}
