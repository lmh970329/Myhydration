//
//  DayRepeatSelectionView.swift
//  MyHydration
//
//  Created by 이민하 on 2021/10/08.
//

import SwiftUI

struct DayRepeatSelectionView: View {
    
  //  @Binding var dayRepeats: [DayRepeat]
    @Binding var weekDays: [WeekDay]
    
    var body: some View {
        List {
            ForEach(WeekDay.allCases) { weekDay in
                Button(action: { updateWeekday(weekDay: weekDay) }) {
                    HStack {
                        Text("\(weekDay.toString())요일마다").foregroundColor(.black).font(.body)
                        Spacer()
                        if weekDays.contains(weekDay) {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
    }
    
    func updateWeekday(weekDay: WeekDay) {
        if weekDays.contains(weekDay) {
            let idx = weekDays.firstIndex(where: { $0 == weekDay })
            weekDays.remove(at: idx!)
        } else {
            weekDays.append(weekDay)
        }
        
        weekDays.sort(by: <)
    }
}

struct DayRepeatSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        DayRepeatSelectionView(weekDays: .constant([.sun, .mon]))
    }
}



