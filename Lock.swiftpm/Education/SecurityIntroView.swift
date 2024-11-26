//
//  SecurityIntroView.swift
//  Lock
//
//  Created by Morris Richman on 11/22/24.
//

import SwiftUI
import Charts

struct SecurityIntroView: View {
    @Environment(EductionNavigationController.self) var educationNavigationController
    @State var isShowingTitle = false
    @State var isShowingGetStarted = false
    @State var isShowingCrimeLosses = false
    @State var isShowingHackRate = false
    @State var isShowingPhishingStat = false
    @State var isShowingNotGoodPopup = false
    @Namespace var namespace
    
    var isShowingStats: Bool {
        isShowingCrimeLosses || isShowingHackRate || isShowingPhishingStat
    }
    
    var body: some View {
        VStack(spacing: 60) {
            Text("The State of Online Security")
                .font(.title)
                .bold()
                .opacity(isShowingTitle ? 1 : 0)
            
            if !isShowingStats {
                Button(action: next) {
                    Text("Get Started")
                        .padding()
                        .foregroundColor(.white)
                        .frame(maxWidth: 800)
                        .background(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .matchedGeometryEffect(id: "button", in: namespace)
                .opacity(isShowingGetStarted ? 1 : 0)
            }
            
            if isShowingStats {
                HStack(alignment: .top, spacing: 60) {
                    if isShowingCrimeLosses {
                        PrimaryElement(text: "In 2023, more than $12 billion were lost to cybercrime in the US alone. Cybersecurity Ventures is predicting a worldwide loss of $15 trillion in 2025.") {
                            CybercrimeLossesGraphic()
                        }
                        .transition(.move(edge: .trailing))
                    }
                    
                    if isShowingHackRate {
                        PrimaryElement(text: "At least one account is hacked every 39 seconds. This totals to at least 800,000 accounts each year. This is expected to grow over time along with the severity of attack.") {
                            Image(systemName: "arrow.trianglehead.clockwise")
                                .resizable()
                                .overlay {
                                    GeometryReader { geo in
                                        Text("39")
                                            .bold()
                                            .font(.system(size: geo.size.height/2.5))
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                            .offset(y: 10)
                                    }
                                }
                                .aspectRatio(contentMode: .fit)
                        }
                        .transition(.move(edge: .trailing))
                    }
                    
                    if isShowingPhishingStat {
                        PrimaryElement(text: "More than 22% of hacks begin with phishing. This is expected to grow over time.", named: "custom.22.square.badge.plus")
                            .transition(.move(edge: .trailing))
                    }
                }
                .frame(maxHeight: 300)
            }
        }
        .frame(maxWidth: 800, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom, content: {
            if isShowingStats {
                Button(action: next) {
                    Text("Next")
                        .padding()
                        .foregroundColor(.white)
                        .frame(maxWidth: 800)
                        .background(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .matchedGeometryEffect(id: "button", in: namespace)
            }
        })
        .padding()
        .task {
            try? await Task.sleep(for: .seconds(1))
            
            withAnimation {
                isShowingTitle = true
            }
            
            try? await Task.sleep(for: .milliseconds(1500))
            
            withAnimation {
                isShowingGetStarted = true
            }
        }
        .overlay {
            GeometryReader { geo in
                VStack(spacing: 30) {
                    Image(systemName: "exclamationmark")
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(.red)
                    Text("This is Not Good")
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(.red)
                    
                    Button(action: next) {
                        HStack(spacing: 15) {
                            Text("Secure My Accounts")
                            Image(systemName: "chevron.right")
                                .resizable()
                                .frame(width: 8, height: 13)
                        }
                            .padding()
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: 600)
                            .background(Color("secureAccountsColor"))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .frame(maxWidth: 600, maxHeight: 400)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(uiColor: .systemBackground))
                        .shadow(radius: 10, y: 5)
                )
                .scaleEffect(isShowingNotGoodPopup ? 1 : 0.4)
                .offset(x: 0, y: isShowingNotGoodPopup ? 0 : -geo.size.height)
                .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            }
            .allowsHitTesting(isShowingNotGoodPopup)
//            .background {
//                Color.red
//            }
        }
    }
    
    func next() {
        guard isShowingCrimeLosses else {
            withAnimation {
                self.isShowingCrimeLosses = true
            }
            return
        }
        
        guard isShowingHackRate else {
            withAnimation {
                self.isShowingHackRate = true
            }
            return
        }
        
        guard isShowingPhishingStat else {
            withAnimation {
                self.isShowingPhishingStat = true
            }
            return
        }
        
        guard isShowingNotGoodPopup else {
            withAnimation {
                self.isShowingNotGoodPopup = true
            }
            return
        }
        
        withAnimation {
            educationNavigationController.shownView.next()
        }
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
        return Gradient(colors: [Color.red, Color.red.opacity(0.1)])
      }
    
    var body: some View {
        Chart {
            ForEach(visibleYears.sorted(by: >), id: \.self) { key in
                if let value = data[key] {
                    LineMark(x: .value("Year", key), y: .value("Dollar", value))
                        .symbol(Circle())
                        .foregroundStyle(Color.red)
                    
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

private struct PrimaryElement<Content: View>: View {
    let text: LocalizedStringKey
    @ViewBuilder var content: Content
    
    init(text: LocalizedStringKey, @ViewBuilder content: () -> Content) {
        self.text = text
        self.content = content()
    }
    
    init(text: LocalizedStringKey, systemName: String) where Content == SystemImage {
        self.text = text
        self.content = SystemImage(systemName: systemName)
    }
    
    init(text: LocalizedStringKey, named: String) where Content == AssetImage {
        self.text = text
        self.content = AssetImage(name: named)
    }
    
    var body: some View {
        VStack(spacing: 30) {
            content
            
            Text(text)
                .frame(maxHeight: 200, alignment: .top)
        }
    }
}

private struct SystemImage: View {
    let systemName: String
    
    var body: some View {
        Image(systemName: systemName)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

private struct AssetImage: View {
    let name: String
    
    var body: some View {
        Image(name)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .scaleEffect(0.8)
    }
}

#Preview {
    SecurityIntroView()
        .environment(EductionNavigationController())
}
