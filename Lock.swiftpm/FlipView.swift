//
//  FlipView.swift
//  Lock
//
//  Created by Morris Richman on 11/18/24.
//

import SwiftUI

struct FlipView<FrontView: View, BackView: View>: View {

    @Binding var showBack: Bool
    @ViewBuilder var frontView: FrontView
    @ViewBuilder var backView: BackView


      var body: some View {
          ZStack {
                frontView
                  .modifier(FlipOpacity(percentage: showBack ? 0 : 1))
                  .rotation3DEffect(Angle.degrees(showBack ? 180 : 360), axis: (0,1,0))
                backView
                  .modifier(FlipOpacity(percentage: showBack ? 1 : 0))
                  .rotation3DEffect(Angle.degrees(showBack ? 0 : 180), axis: (0,1,0))
          }
      }
}

private struct FlipOpacity: AnimatableModifier {
   var percentage: CGFloat = 0
   
    nonisolated var animatableData: CGFloat {
      get { percentage }
      set { percentage = newValue }
   }
   
   func body(content: Content) -> some View {
      content
           .opacity(Double(percentage.rounded()))
   }
}
