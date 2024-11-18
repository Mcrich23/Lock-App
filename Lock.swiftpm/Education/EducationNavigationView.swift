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
        case poorPassword, createPassword
        
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
    @Environment(\.colorScheme) var colorScheme
    @State var educationNavigationController = EductionNavigationController()
    
    var body: some View {
        VStack {
            switch educationNavigationController.shownView {
            case .poorPassword:
                PoorPasswordView()
                    .fillSpaceAvailable()
//                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case .createPassword:
                CreatePasswordView()
                    .fillSpaceAvailable()
//                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                    .background(
                        Color(uiColor: colorScheme == .light ? .systemBackground: .secondarySystemBackground)
                            .ignoresSafeArea()
                        .environment(\.colorScheme, .dark)
                    )
                    .environment(\.colorScheme, .dark)
                    .transition(.scale)
            }
        }
        .environment(educationNavigationController)
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
