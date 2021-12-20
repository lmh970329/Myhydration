//
//  UserInformationView.swift
//  MyHydration
//
//  Created by 이민하 on 2021/09/27.
//

import SwiftUI

struct UserInformationView: View {
    @Binding var userData: UserData
    @State var data: UserData.Data = UserData.Data(userName: "", dailyGoal: 0)
    @State var isPresented: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("기본 정보") {
                    HStack {
                        Label("사용자 이름", systemImage: "person.fill")
                        Spacer()
                        Text("\(userData.userName ?? "")")
                    }
                    HStack {
                        Label("일일 목표량", systemImage: "drop.fill")
                        Spacer()
                        Text("\(Int(userData.dailyGoal ?? 1800)) mL")
                    }
                }
            }
            .navigationTitle("사용자 정보")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("편집") {
                        isPresented.toggle()
                        data = userData.data
                    }
                }
            }
            .fullScreenCover(isPresented: $isPresented) {
                NavigationView {
                    UserInformationEditView(userData: $data)
                        .navigationTitle("사용자 정보 편집")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("취소") {
                                    isPresented.toggle()
                                }
                            }
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("저장") {
                                    userData.userName = data.userName
                                    userData.dailyGoal = Int(data.dailyGoal)
                                    isPresented.toggle()
                                }.disabled(data.userName == "")
                            }
                        }
                }
            }

        }
    }
}

struct UserInformationView_Previews: PreviewProvider {
    static var previews: some View {
        UserInformationView(userData: .constant(UserData()))
    }
}
