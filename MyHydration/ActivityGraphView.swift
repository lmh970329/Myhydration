//
//  AcitivyGraphView.swift
//  MyHydration
//
//  Created by 이민하 on 2021/10/22.
//

import Foundation
import Charts
import SwiftUI

struct ActivityGraphView: UIViewRepresentable {
    var hydrationData: [Hydration]
    @Binding var dateTab: DateTab
    @Environment(\.locale) var locale: Locale
    
    let barChart = BarChartView()
    
    func makeUIView(context: Context) -> BarChartView {
        barChart.delegate = context.coordinator
        return barChart
    }
    
    func updateUIView(_ uiView: BarChartView, context: Context) {
        let calendar = Calendar.current
        var dataArray: [Double]
        
        switch dateTab {
        case .year:
            let dateInterval = calendar.dateInterval(of: .year, for: Date())
            let filteredData = hydrationData.filter { hydration in
                return hydration.date > dateInterval!.start
            }
            dataArray = Array(repeating: 0, count: 12)
            for datum in filteredData {
                dataArray[datum.dateComponent.month!-1] += datum.intake
            }
            let enumerated = dataArray.enumerated()
            let dataEntry = enumerated.map { BarChartDataEntry(x: Double($0.offset), y: $0.element) }
            let dataSet = BarChartDataSet(entries: dataEntry)
            formatDataSet(dataSet: dataSet)
            uiView.data = BarChartData(dataSet: dataSet)

        case .month:
            let dateInterval = calendar.dateInterval(of: .month, for: Date())
            let endDay = calendar.component(.day, from: Date(timeInterval: -1, since: dateInterval!.end))
            
            let filterdData = hydrationData.filter { hydration in
                return hydration.date > dateInterval!.start
            }
            dataArray = Array(repeating: 0, count: endDay)
            for datum in filterdData {
                dataArray[datum.dateComponent.day!-1] += datum.intake
            }
            let enumerated = dataArray.enumerated()
            let dataEntry = enumerated.map { BarChartDataEntry(x: Double($0.offset+1), y: $0.element) }
            let dataSet = BarChartDataSet(entries: dataEntry)
            formatDataSet(dataSet: dataSet)
            uiView.data = BarChartData(dataSet: dataSet)

        case .week:
            let dateInterval = calendar.dateInterval(of: .weekOfMonth, for: Date())
            let filteredData = hydrationData.filter { hydration in
                return hydration.date > dateInterval!.start
            }
            dataArray = Array(repeating: 0, count: 7)
            for datum in filteredData {
                dataArray[datum.dateComponent.weekday!-1] += datum.intake
            }
            let enumerated = dataArray.enumerated()
            let dataEntry = enumerated.map { BarChartDataEntry(x: Double($0.offset), y: $0.element)}
            let dataSet = BarChartDataSet(entries: dataEntry)
            formatDataSet(dataSet: dataSet)
            uiView.data = BarChartData(dataSet: dataSet)
        }

        formatLeftAxis(leftAxis: uiView.leftAxis)
        formatXAxis(xAxis: uiView.xAxis)
        if let barData = uiView.barData {
            formatBarData(barData: barData)
        }
        uiView.rightAxis.axisMinimum = 0
        uiView.setScaleEnabled(false)
        uiView.legend.enabled = false
    }

    class Coordinator: NSObject, ChartViewDelegate {
        let parent: ActivityGraphView
        init(parent: ActivityGraphView) {
            self.parent = parent
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func formatLeftAxis(leftAxis: YAxis) {
        leftAxis.axisMinimum = 0
        leftAxis.enabled = false
    }

    func formatXAxis(xAxis: XAxis) {
        xAxis.drawGridLinesEnabled = false
        xAxis.labelPosition = .bottom
        var calendar = Calendar.current
        calendar.locale = locale
        if dateTab == .week {
            xAxis.valueFormatter = IndexAxisValueFormatter(values: calendar.shortStandaloneWeekdaySymbols)
        } else if dateTab == .year {
            xAxis.valueFormatter = IndexAxisValueFormatter(values: calendar.shortStandaloneMonthSymbols)
        } else {
            let formatter = NumberFormatter()
            xAxis.valueFormatter = DefaultAxisValueFormatter(formatter: formatter)
        }
    }

    func formatBarData(barData: BarChartData) {
        barData.barWidth = 0.7
    }

    func formatDataSet(dataSet: BarChartDataSet) {
        dataSet.drawValuesEnabled = false
    }
}

struct ActivityGraphView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityGraphView(hydrationData: Hydration.allHydration(), dateTab: .constant(DateTab.week)).environment(\.locale, Locale(identifier: "ko_KR"))
    }
}
