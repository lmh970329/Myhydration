//
//  HydrationActivityView.swift
//  MyHydration
//
//  Created by 이민하 on 2021/09/27.
//

import SwiftUI

struct HydrationActivityView: View {
    @Binding var hydrations: [Hydration]
    @State private var dateTab: DateTab = .week
    
    var body: some View {
        NavigationView {
            VStack {
                Picker(selection: $dateTab, label: Text("보기 선택")) {
                    Text("연").tag(DateTab.year)
                    Text("월").tag(DateTab.month)
                    Text("주").tag(DateTab.week)
                }.pickerStyle(.segmented)
                
                ActivityGraphView(hydrationData: hydrations, dateTab: $dateTab)
                
                Spacer()
            }.padding()
            .navigationTitle("사용자 활동")
            .navigationBarTitleDisplayMode(.automatic)
        }

    }
}

struct HydrationActivityView_Previews: PreviewProvider {
    static var previews: some View {
        HydrationActivityView(hydrations: .constant(Hydration.allHydration()))
    }
}

enum DateTab: String {
    case year = "연"
    case month = "월"
    case week = "주"
}
