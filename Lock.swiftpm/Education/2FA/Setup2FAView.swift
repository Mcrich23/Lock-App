//
//  Setup2FAView.swift
//  Lock
//
//  Created by Morris Richman on 11/18/24.
//

import SwiftUI

struct Setup2FAView: View {
    var body: some View {
        VStack {
            Text("Setup 2 Factor Authentication")
                .font(.title)
            
            UpsideDownAccuteTriangle()
                .overlay(alignment: .topLeading) {
                    Image(systemName: "key.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .foregroundStyle(Color.accentColor)
                        .background(Color(uiColor: .systemBackground))
                        .offset(y: -12)
                }
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "key.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .foregroundStyle(Color.accentColor)
                        .background(Color(uiColor: .systemBackground))
                        .offset(x: 25, y: -12)
                }
                .overlay(alignment: .bottom) {
                    Image(systemName: "lock.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .foregroundStyle(Color.green)
                        .background(Color(uiColor: .systemBackground))
                        .offset(x: 10, y: 25)
                }
        }
    }
}

struct UpsideDownAccuteTriangle: View {
    func topRightOffset(_ geometrySize: CGSize) -> CGSize {
        .init(width: geometrySize.width, height: 0)
    }
    
    func bottomLeftOffset(_ geometrySize: CGSize) -> CGSize {
        .init(width: 0, height: geometrySize.height)
    }
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            
            ZStack {
                // First Row
                MovingCircle(startingOffset: .init(width: 0, height: 0), topRightOffset: topRightOffset(geo.size), bottonLeftOffset: bottomLeftOffset(geo.size))
                MovingCircle(startingOffset: .init(width: width-(width/3), height: 0), topRightOffset: topRightOffset(geo.size), bottonLeftOffset: bottomLeftOffset(geo.size))
                MovingCircle(startingOffset: .init(width: width-2*(width/3), height: 0), topRightOffset: topRightOffset(geo.size), bottonLeftOffset: bottomLeftOffset(geo.size))
                MovingCircle(startingOffset: .init(width: width, height: 0), topRightOffset: topRightOffset(geo.size), bottonLeftOffset: bottomLeftOffset(geo.size))
                
                // Second Row
                MovingCircle(startingOffset: .init(width: width-(width/6), height: height-2*(height/3)), topRightOffset: topRightOffset(geo.size), bottonLeftOffset: bottomLeftOffset(geo.size))
                MovingCircle(startingOffset: .init(width: (width/6), height: height-2*(height/3)), topRightOffset: topRightOffset(geo.size), bottonLeftOffset: bottomLeftOffset(geo.size))
                
                // Third Row
                MovingCircle(startingOffset: .init(width: width-2*(width/6), height: height-(height/3)), topRightOffset: topRightOffset(geo.size), bottonLeftOffset: bottomLeftOffset(geo.size))
                MovingCircle(startingOffset: .init(width: 2*(width/6), height: height-(height/3)), topRightOffset: topRightOffset(geo.size), bottonLeftOffset: bottomLeftOffset(geo.size))
                
                // Fourth Row
                MovingCircle(startingOffset: .init(width: width/2, height: height), topRightOffset: topRightOffset(geo.size), bottonLeftOffset: bottomLeftOffset(geo.size))
            }
        }
        .frame(width: 250, height: 250)
    }
    
    struct MovingCircle: View {
        let startingOffset: CGSize
        let topRightOffset: CGSize
        let bottonLeftOffset: CGSize
        
        init(startingOffset: CGSize, topRightOffset: CGSize, bottonLeftOffset: CGSize) {
            self.startingOffset = startingOffset
            self.topRightOffset = topRightOffset
            self.bottonLeftOffset = bottonLeftOffset
            
            self._currentOffset = .init(initialValue: startingOffset)
            
            if startingOffset.height == 0 && startingOffset.width != topRightOffset.width && startingOffset.width != bottonLeftOffset.width {
                self.side = .top
            } else if startingOffset.width < topRightOffset.width/2 || startingOffset.height == bottonLeftOffset.height {
                self.side = .left
            } else {
                self.side = .right
            }
        }
        
        @State var currentOffset: CGSize
        @State var side: Side
        let timer = Timer.publish(every: 0.001, on: .main, in: .common).autoconnect()
        
        enum Side {
            case top, right, left
        }
        
        var body: some View {
            Circle()
                .frame(width: 25, height: 25)
                .offset(currentOffset)
                .onReceive(timer) { _ in
                    moveCircle()
                }
        }
        
        func moveCircle() {
            switch side {
            case .top:
                currentOffset.width += 0.1
            case .right:
                currentOffset.width -= 0.05
                currentOffset.height += 0.1
            case .left:
                currentOffset.width -= 0.05
                currentOffset.height -= 0.1
            }
            setSide()
        }
        
        func setSide() {
            if currentOffset.height <= 0 && currentOffset.width <= 0 {
                currentOffset = .init(width: 0, height: 0)
            }
            
            if currentOffset.height == 0 && currentOffset.width <= topRightOffset.width && currentOffset.width >= bottonLeftOffset.width {
                self.side = .top
            } else if currentOffset.width < topRightOffset.width/2 || currentOffset.height == bottonLeftOffset.height {
                self.side = .left
            } else {
                self.side = .right
            }
        }
    }
}

#Preview {
    Setup2FAView()
}
