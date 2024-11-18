//
//  EducationNavigationView.swift
//  Pass
//
//  Created by Morris Richman on 11/17/24.
//

import SwiftUI

struct EducationNavigationView: View {
    enum ShownView: Int {
        case poorPassword
        
        mutating func next() {
            if let newValue = ShownView(rawValue: self.rawValue + 1) {
                self = newValue
            }
        }
        
        mutating func previous() {
            if let newValue = ShownView(rawValue: self.rawValue - 1) {
                self = newValue
            }
        }
    }
    
    @State var shownView: ShownView = .poorPassword
    
    var body: some View {
        switch shownView {
        case .poorPassword:
            PoorPasswordView()
                .fillSpaceAvailable()
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
        }
    }
}
struct FillAllSpaceModifier: ViewModifier {
    func body(content: Content) -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                content
                Spacer()
            }
            Spacer()
        }
    }
}

extension View {
    func fillSpaceAvailable() -> some View {
        modifier(FillAllSpaceModifier())
    }
}
