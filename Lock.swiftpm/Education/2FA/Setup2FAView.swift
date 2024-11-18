//
//  Setup2FAView.swift
//  Lock
//
//  Created by Morris Richman on 11/18/24.
//

import SwiftUI
import Combine

struct Setup2FAView: View {
    let timer = UpsideDownAccuteTriangle.defaultTimer
    
    var body: some View {
        VStack {
            Text("Setup 2 Factor Authentication")
                .font(.title)
            
            ZStack {
                UpsideDownAccuteTriangle(timer: timer, visibleSides: [.right])
                    .environment(\.direction, .right)
                UpsideDownAccuteTriangle(timer: timer, visibleSides: [.left])
                    .environment(\.direction, .left)
            }
                .overlay(alignment: .topLeading) {
                    Image(systemName: "key.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .foregroundStyle(Color.accentColor)
                        .background(Color(uiColor: .systemBackground))
                        .offset(x: -12, y: -12)
                }
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "key.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .foregroundStyle(Color.accentColor)
                        .background(Color(uiColor: .systemBackground))
                        .offset(x: 20, y: -12)
                }
                .overlay(alignment: .bottom) {
                    Image(systemName: "lock.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .foregroundStyle(Color.green)
                        .background(
                            Color(uiColor: .systemBackground)
                                .frame(width: 25, height: 25)
                                .clipShape(Circle())
                                .offset(y: -12)
                        )
                        .offset(x: 3, y: 30)
                }
        }
    }
}

struct UpsideDownAccuteTriangle: View {
    let visibleSides: [Side]
    let timer: Publishers.Autoconnect<Timer.TimerPublisher>
    static let defaultTimer = Timer.publish(every: 0.001, on: .main, in: .common).autoconnect()
    
    init(timer: Publishers.Autoconnect<Timer.TimerPublisher> = UpsideDownAccuteTriangle.defaultTimer, visibleSides: [Side] = Side.allCases) {
        self.timer = timer
        self.visibleSides = visibleSides
    }
    
    enum Side: CaseIterable {
        case top, right, left
    }
    
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
                MovingCircle(startingOffset: .init(width: 0, height: 0), topRightOffset: topRightOffset(geo.size), bottonLeftOffset: bottomLeftOffset(geo.size), visibleSides: visibleSides, timer: timer)
                MovingCircle(startingOffset: .init(width: width-(width/3), height: 0), topRightOffset: topRightOffset(geo.size), bottonLeftOffset: bottomLeftOffset(geo.size), visibleSides: visibleSides, timer: timer)
                MovingCircle(startingOffset: .init(width: width-2*(width/3), height: 0), topRightOffset: topRightOffset(geo.size), bottonLeftOffset: bottomLeftOffset(geo.size), visibleSides: visibleSides, timer: timer)
                MovingCircle(startingOffset: .init(width: width, height: 0), topRightOffset: topRightOffset(geo.size), bottonLeftOffset: bottomLeftOffset(geo.size), visibleSides: visibleSides, timer: timer)
     
                // Second Row
                MovingCircle(startingOffset: .init(width: width-(width/6), height: height-2*(height/3)), topRightOffset: topRightOffset(geo.size), bottonLeftOffset: bottomLeftOffset(geo.size), visibleSides: visibleSides, timer: timer)
                MovingCircle(startingOffset: .init(width: (width/6), height: height-2*(height/3)), topRightOffset: topRightOffset(geo.size), bottonLeftOffset: bottomLeftOffset(geo.size), visibleSides: visibleSides, timer: timer)

                // Third Row
                MovingCircle(startingOffset: .init(width: width-2*(width/6), height: height-(height/3)), topRightOffset: topRightOffset(geo.size), bottonLeftOffset: bottomLeftOffset(geo.size), visibleSides: visibleSides, timer: timer)
                MovingCircle(startingOffset: .init(width: 2*(width/6), height: height-(height/3)), topRightOffset: topRightOffset(geo.size), bottonLeftOffset: bottomLeftOffset(geo.size), visibleSides: visibleSides, timer: timer)
                
                // Fourth Row
                MovingCircle(startingOffset: .init(width: width/2, height: height), topRightOffset: topRightOffset(geo.size), bottonLeftOffset: bottomLeftOffset(geo.size), visibleSides: visibleSides, timer: timer)
            }
        }
        .frame(width: 250, height: 250)
    }
    
    struct MovingCircle: View {
        let startingOffset: CGSize
        let topRightOffset: CGSize
        let bottonLeftOffset: CGSize
        let visibleSides: [Side]
        @Environment(\.direction) var direction
        let timer: Publishers.Autoconnect<Timer.TimerPublisher>
        
        init(startingOffset: CGSize, topRightOffset: CGSize, bottonLeftOffset: CGSize, visibleSides: [Side] = Side.allCases, timer: Publishers.Autoconnect<Timer.TimerPublisher> = UpsideDownAccuteTriangle.defaultTimer) {
            self.startingOffset = startingOffset
            self.topRightOffset = topRightOffset
            self.bottonLeftOffset = bottonLeftOffset
            self.visibleSides = visibleSides
            self.timer = timer
            
            self._currentOffset = .init(initialValue: startingOffset)
            
            if startingOffset.height == 0 && startingOffset.width != topRightOffset.width && startingOffset.width != bottonLeftOffset.width {
                self.side = .top
            } else if startingOffset.width < topRightOffset.width/2 || startingOffset.height == bottonLeftOffset.height {
                self.side = .left
            } else {
                self.side = .right
            }
            setSide()
        }
        
        @State var currentOffset: CGSize
        @State var side: Side
        
        var rotation: Double {
            switch side {
            case .top:
                return 90
            case .left:
                return -25
            case .right:
                return 25
            }
        }
        
        var body: some View {
            Rectangle()
                .frame(width: 6, height: 30)
                .rotationEffect(.degrees(rotation))
                .offset(currentOffset)
                .onReceive(timer) { _ in
                    moveCircle()
                }
                .opacity(visibleSides.contains(side) ? 1 : 0)
        }
        
        func moveCircle() {
            switch direction {
            case .right:
                moveCircleRight()
            case .left:
                moveCircleLeft()
            }
        }
        
        func moveCircleRight() {
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
        
        func moveCircleLeft() {
            switch side {
            case .top:
                currentOffset.width -= 0.1
            case .right:
                currentOffset.width += 0.05
                currentOffset.height -= 0.1
            case .left:
                currentOffset.width += 0.05
                currentOffset.height += 0.1
            }
            setSide()
        }
        
        func setSide() {
            switch direction {
            case .left:
                if currentOffset.height <= 0 && currentOffset.width >= topRightOffset.width {
                    currentOffset = topRightOffset
                }
                
                if currentOffset.height == 0 && currentOffset.width <= topRightOffset.width && currentOffset.width >= bottonLeftOffset.width {
                    self.side = .top
                } else if currentOffset.width > topRightOffset.width/2 || currentOffset.height == bottonLeftOffset.height {
                    self.side = .right
                } else {
                    self.side = .left
                }
            case .right:
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
}

enum Direction {
    case right, left
}

extension EnvironmentValues {
    @Entry var direction = Direction.right
}

#Preview {
    Setup2FAView()
}
