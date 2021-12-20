//
//  TrackerRingView.swift
//  MyHydration
//
//  Created by 이민하 on 2021/09/27.
//

import SwiftUI
import Foundation

struct HydratedArc: Shape {
    var proportion: Double
    
    var animatableData: CGFloat {
        get { proportion }
        set { proportion = newValue }
    }
    
    private var endAngle: Angle {
        Angle(degrees: 360.0 * proportion)
    }
    
    func path(in rect: CGRect) -> Path {
        let diameter = min(rect.size.width, rect.size.height) - 24.0
        let radius = diameter / 2.0
        let center = CGPoint(x: rect.origin.x + rect.size.width / 2.0,
                             y: rect.origin.y + rect.size.height / 2.0)
        
        return Path { path in
            path.addArc(center: center, radius: radius, startAngle: Angle(degrees: 0), endAngle: endAngle, clockwise: false)
        }
    }
}

struct TrackerRingView: View {
    
    var dailyGoal: Int
    var currentHydration: Int

    private var proportion: Double {
        return Double(currentHydration) / Double(dailyGoal)
    }
    
    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(lineWidth: 24.0, antialiased: true)
                .foregroundColor(.gray.opacity(0.45))
                .scaledToFit()
            HydratedArc(proportion: proportion)
                .stroke(lineWidth: 24.0)
                .rotation(Angle(degrees: -90))
                .foregroundColor(Color(red: 104/255, green: 150/255, blue: 203/255))
                .animation(.default, value: currentHydration)
            VStack {
                Text(String(format: "%.1f", proportion * 100)+"%")
                    .fontWeight(.bold)
                    .font(.system(size: 56))
                    .padding(.top)
                    .padding(.bottom)
                    
                Text("\(currentHydration) mL / \(dailyGoal) mL")
                    .font(.body)
            }
        }
    }
}

struct TrackerRingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VStack {
                TrackerRingView(dailyGoal: 2000, currentHydration: 1110)
            }
        }
    }
}

extension Animation {
    
}
