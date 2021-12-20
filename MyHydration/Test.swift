//
//  Test.swift
//  MyHydration
//
//  Created by 이민하 on 2021/11/11.
//

import SwiftUI

struct Test: View {
    @State var isClicked: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                TrackerRingView(dailyGoal: 2000, currentHydration: 110)
                    .navigationTitle("수분 섭취")
                    .padding(5)
                    .listRowSeparator(.hidden)
                .navigationBarTitleDisplayMode(.automatic)
            }
            .listStyle(.inset)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        isClicked.toggle()
                    }) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .rotationEffect(.degrees(isClicked ? 90 : 0))
                    }
                }
            }
        }
    }
}

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
