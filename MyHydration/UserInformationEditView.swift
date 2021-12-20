//
//  UserInformationEditView.swift
//  MyHydration
//
//  Created by 이민하 on 2021/10/21.
//

import SwiftUI

struct UserInformationEditView: View {
    @Binding var userData: UserData.Data
    
    var body: some View {
        Form {
            Section("사용자 이름") {
                TextField("사용자 이름", text: $userData.userName)
            }
            Section("일일 목표량") {
                VStack {
                    Text("\(Int(userData.dailyGoal)) mL").font(.title)
                    Slider(value: $userData.dailyGoal, in: 1000...3000, step: 100.0) {
                        Text("Goal")
                    } minimumValueLabel: {
                        Text("1000")
                    } maximumValueLabel: {
                        Text("3000")
                    }
                }
            }
        }
    }
}

struct UserInformationEditView_Previews: PreviewProvider {
    static var previews: some View {
        UserInformationEditView(userData: .constant(UserData.Data(userName: "", dailyGoal: 2000)))
    }
}
