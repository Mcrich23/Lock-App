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
            ZStack {
                // First Row
                MovingCircle(startingOffset: .init(width: 0, height: 0), topRightOffset: topRightOffset(geo.size), bottonLeftOffset: bottomLeftOffset(geo.size))
                MovingCircle(startingOffset: .init(width: geo.size.width-geo.size.width/3, height: 0), topRightOffset: topRightOffset(geo.size), bottonLeftOffset: bottomLeftOffset(geo.size))
                MovingCircle(startingOffset: .init(width: geo.size.width-2*(geo.size.width/3), height: 0), topRightOffset: topRightOffset(geo.size), bottonLeftOffset: bottomLeftOffset(geo.size))
                MovingCircle(startingOffset: .init(width: geo.size.width, height: 0), topRightOffset: topRightOffset(geo.size), bottonLeftOffset: bottomLeftOffset(geo.size))
                
                // Second Row
                MovingCircle(startingOffset: .init(width: geo.size.width-0.5*(geo.size.width/3.5), height: geo.size.height-(geo.size.height/1.4)), topRightOffset: topRightOffset(geo.size), bottonLeftOffset: bottomLeftOffset(geo.size))
                MovingCircle(startingOffset: .init(width: geo.size.width-3*(geo.size.width/3.5), height: geo.size.height-(geo.size.height/1.4)), topRightOffset: topRightOffset(geo.size), bottonLeftOffset: bottomLeftOffset(geo.size))
                
                // Third Row
                MovingCircle(startingOffset: .init(width: geo.size.width-1.1*(geo.size.width/3.5), height: geo.size.height-(geo.size.height/2.2)), topRightOffset: topRightOffset(geo.size), bottonLeftOffset: bottomLeftOffset(geo.size))
                MovingCircle(startingOffset: .init(width: geo.size.width-2.4*(geo.size.width/3.5), height: geo.size.height-(geo.size.height/2.2)), topRightOffset: topRightOffset(geo.size), bottonLeftOffset: bottomLeftOffset(geo.size))
                
                // Fourth Row
                MovingCircle(startingOffset: .init(width: geo.size.width-0.99*(geo.size.width/2), height: geo.size.height-(geo.size.height/6.3)), topRightOffset: topRightOffset(geo.size), bottonLeftOffset: bottomLeftOffset(geo.size))
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
        }
        
        var body: some View {
            Circle()
                .frame(width: 25, height: 25)
                .offset(startingOffset)
        }
    }
}

#Preview {
    Setup2FAView()
}
