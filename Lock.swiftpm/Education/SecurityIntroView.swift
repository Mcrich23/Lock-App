//
//  SecurityIntroView.swift
//  Lock
//
//  Created by Morris Richman on 11/22/24.
//

import SwiftUI
import Charts

struct SecurityIntroView: View {
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                VStack {
                    CybercrimeLossesGraphic()
                    Text("In 2023, more than $12 billion were lost to cybercrime in the US alone. Cybersecurity Ventures is predicting a worldwide loss of $15 trillion in 2025.")
                }
                
                if false {
                    PrimaryElement(text: "", systemName: "photo")
                    
                    PrimaryElement(text: "", systemName: "photo")
                }
            }
            .frame(maxHeight: 300)
        }
        .frame(maxWidth: 800)
        .padding()
    }
}

private struct CybercrimeLossesGraphic: View {
    let data: [Int : Double] = [
        2019 : 3.5,
        2020 : 4.2,
        2021 : 6.9,
        2022 : 10.3,
        2023 : 12.5,
//        2024: 15
    ]
    
    @State var visibleYears: [Int] = []
    
    private var areaBackground: Gradient {
        return Gradient(colors: [Color.accentColor, Color.accentColor.opacity(0.1)])
      }
    
    var body: some View {
        Chart {
            ForEach(visibleYears.sorted(by: >), id: \.self) { key in
                if let value = data[key] {
                    LineMark(x: .value("Year", key), y: .value("Dollar", value))
                        .symbol(Circle())
                    
                    AreaMark(x: .value("Year", key), y: .value("Dollar", value))
                        .foregroundStyle(areaBackground)
                }
            }
        }
        .chartXAxis(content: {
            AxisMarks(preset: .aligned) { value in
                if let int = value.as(Int.self) {
                    AxisValueLabel("\(int)".replacingOccurrences(of: ",", with: ""))
                }
            }
        })
        .chartXScale(domain: (2019)...(2023))
        .chartYScale(domain: 0...15)
        .onAppear {
            Task {
                while true {
                    await animateData()
                }
            }
        }
    }
    
    func animateData() async {
        visibleYears.removeAll()
        
        withAnimation {
            visibleYears.append(2019)
        }
        try? await Task.sleep(for: .seconds(1))
        
        withAnimation {
            visibleYears.append(2020)
        }
        try? await Task.sleep(for: .seconds(1))
        
        withAnimation {
            visibleYears.append(2021)
        }
        try? await Task.sleep(for: .seconds(1))
        
        withAnimation {
            visibleYears.append(2022)
        }
        try? await Task.sleep(for: .seconds(1))
        
        withAnimation {
            visibleYears.append(2023)
        }
        try? await Task.sleep(for: .seconds(1))
    }
}

private struct PrimaryElement: View {
    let text: LocalizedStringKey
    let systemName: String
    
    var body: some View {
        VStack {
            Image(systemName: systemName)
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            Text(text)
        }
    }
}

#Preview {
    SecurityIntroView()
}
