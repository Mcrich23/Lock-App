//
//  EducationNavigationView.swift
//  Pass
//
//  Created by Morris Richman on 11/17/24.
//

import SwiftUI

@Observable
class EductionNavigationController {
    enum ShownView: Int {
        case stateOfSecurity, poorPassword, createPasswordSetupMFA
        
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
    
    var shownView: ShownView = .poorPassword
}

struct EducationNavigationView: View {
    @State var educationNavigationController = EductionNavigationController()
    @State var setup2FaFlipDegrees: Double = 0
    
    var body: some View {
        VStack {
            switch educationNavigationController.shownView {
            case .stateOfSecurity:
                SecurityIntroView()
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case .poorPassword:
                PoorPasswordView()
                    .fillSpaceAvailable()
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .identity))
            case .createPasswordSetupMFA:
                CreatePasswordSetupMFA()
                    .transition(.asymmetric(insertion: .scale, removal: .move(edge: .leading)))
            }
        }
        .environment(educationNavigationController)
    }
}

struct CreatePasswordSetupMFA: View {
    @State var isShowingMFA: Bool = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        FlipView(showBack: $isShowingMFA) {
            CreatePasswordView(nextAction: showMFA)
                .fillSpaceAvailable()
                .background(
                    Color(uiColor: colorScheme == .light ? .systemBackground: .secondarySystemBackground)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea()
                    .environment(\.colorScheme, .dark)
                )
                .environment(\.colorScheme, .dark)
        } backView: {
            MFAEductionView(isShowingMFA: isShowingMFA)
        }
    }
    
    func showMFA() {
        withAnimation(.smooth.speed(0.3)) {
            isShowingMFA = true
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
