//
//  AlarmRow.swift
//  MyHydration
//
//  Created by 이민하 on 2021/09/28.
//

import SwiftUI

struct AlarmRow: View {
    @Binding var alarm: Alarm
    @State private var data: Alarm.Data = Alarm.Data()
    @State private var isPresented: Bool = false

    var body: some View {
        Button(action: {
            isPresented.toggle()
            data = alarm.data
        }) {
            HStack {
                Toggle(isOn: $alarm.isActivated, label: {
                    VStack(alignment: .leading) {
                        Text(formatDate(date: alarm.date))
                            .font(.title)
                            .foregroundColor(.black)
                        Text(repeatDescription(weekDays: alarm.weekDays)).font(.footnote).foregroundColor(.black)
                    }
                })
            }.padding()
        }.sheet(isPresented: $isPresented) {
            NavigationView {
                VStack {
                    AlarmEditView(alarmData: $data, isPresented: $isPresented, alarm: alarm)
                        .navigationTitle("알람 편집")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("취소", role: .cancel) {
                                    isPresented.toggle()
                                }
                            }
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("저장") {
                                    isPresented.toggle()
                                    alarm.update(from: data)
                                }
                            }
                    }
                }
            }
        }
    }
}

struct AlarmRow_Previews: PreviewProvider {
    static var previews: some View {
        AlarmRow(alarm: .constant(Alarm(date: Date(), weekDays: [])))
    }
}
