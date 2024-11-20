//
//  CircleCountdownView.swift
//  Lock
//
//  Created by Morris Richman on 11/20/24.
//

import SwiftUI

struct CircleCountdownView: View {
    let progress: Double
    
    var body: some View {
        Circle()
            .trim(from: 0, to: progress)
            .fill(Color.clear)
            .stroke(Color.accentColor, style: .init(lineWidth: 4))
            .rotationEffect(.degrees(-90))
            .animation(.easeInOut, value: progress == 1 ? progress : nil)
    }
}

#Preview {
    @Previewable @State var progress: Double = 0.0
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    CircleCountdownView(progress: progress)
        .onReceive(timer) {_ in
            guard progress < 1 else {
                progress = 0
                return
            }
            progress += 0.001
        }
}
