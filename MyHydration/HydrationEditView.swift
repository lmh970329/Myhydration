//
//  HydrationEditView.swift
//  MyHydration
//
//  Created by 이민하 on 2021/10/06.
//

import SwiftUI

struct HydrationEditView: View {
    @Binding var showHydrationEditView: Bool
    @Binding var newHydration: Double
    @Binding var currentHydration: Int
    @Binding var presets: [Int]
    @Binding var hydrations: [Hydration]
    
    @State private var showPresetAdd: Bool = false
    @State private var presetValue: Double = 10
    
    var body: some View {
        NavigationView {
            List {
                Section(header: HStack {
                    Text("custom").font(.headline)
                }) {
                    VStack(spacing: 10) {
                        Text("\(Int(newHydration)) mL").font(.title)
                        Slider(value: $newHydration, in: 10...1000, step: 10.0) {
                            Text("intake")
                        } minimumValueLabel: {
                            Text("10 mL")
                        } maximumValueLabel: {
                            Text("1,000 mL")
                        }
                    }
                }
                Section(header: HStack {
                    Text("preset").font(.headline)
                    Spacer()
                }) {
                    ForEach(presets, id: \.self) { quantity in
                        HStack {
                            Button(action: {
                                addHydration(Double(quantity))
                                showHydrationEditView.toggle()
                            }) {
                                Text("\(quantity) mL").foregroundColor(.black)
                            }
                        }
                    }
                    .onDelete { self.deletePreset(at: $0) }
                    
                    Button(action: {
                        showPresetAdd.toggle()
                    }) {
                        Label("Add Preset", systemImage: "plus")
                    }.sheet(isPresented: $showPresetAdd) {
                        NavigationView {
                            List {
                                VStack(spacing: 10) {
                                    Text("\(Int(presetValue)) mL").font(.title)
                                    Slider(value: $presetValue, in: 10...1000, step: 10.0) {
                                        Text("preset")
                                    } minimumValueLabel: {
                                        Text("10 mL")
                                    } maximumValueLabel: {
                                        Text("1000 mL")
                                    }
                                    Spacer()
                                }
                                .navigationBarTitle("프리셋 추가")
                                .navigationBarTitleDisplayMode(.inline)
                                .navigationBarItems(
                                    leading: Button("취소", role: .cancel, action: {
                                        presetValue = 10
                                        showPresetAdd.toggle() }),
                                    trailing: Button("저장", action: {
                                        addPreset(presetValue)
                                        presetValue = 10
                                        showPresetAdd.toggle()
                                }))
                            }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소", role: .cancel, action: {
                        showHydrationEditView.toggle()
                    })
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("추가", action: {
                        addHydration(newHydration)
                        showHydrationEditView.toggle()
                    })
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("수분 섭취량 추가")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func addHydration(_ intake: Double) {
        currentHydration = currentHydration + Int(intake)
        hydrations.append(Hydration(intake: intake))
    }
    
    func addPreset(_ intake: Double) {
        if presets.contains(Int(intake)) {
            return
        } else {
            presets.append(Int(intake))
        }
    }
    
    func deletePreset(at ids: IndexSet) {
        for idx in ids {
            presets.remove(at: idx)
        }
    }
}

struct HydrationEditView_Previews: PreviewProvider {
    static var previews: some View {
        HydrationEditView(showHydrationEditView: .constant(true), newHydration: .constant(150), currentHydration: .constant(1000), presets: .constant([150, 200, 50, 100]), hydrations: .constant([]))
    }
}
