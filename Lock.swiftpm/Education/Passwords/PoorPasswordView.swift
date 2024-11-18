import SwiftUI

struct PoorPasswordView: View {
    @Environment(EductionNavigationController.self) var navigationController
    
    @State var password: String = ""
    @State var isShowingHint: Bool = false
    @State var isShowingIncorrectPassword = false
    
    @FocusState var isPasswordFieldFocused: Bool
    
    let correctPassword = "Password123"
    
    var body: some View {
        VStack {
            Image(systemName: "lock")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.accentColor)
            Text("Welcome to Lock")
                .font(.title)
            
            HStack {
                TextField("Enter your password", text: $password)
                    .onSubmit {
                        checkPassword()
                    }
                    .textFieldStyle(.custom)
                    .frame(maxWidth: 350)
                    .focused($isPasswordFieldFocused)
                    .padding(.horizontal)
                    .textInputAutocapitalization(.never)
                    .overlay(alignment: .trailing) {
                        Button {
                            isShowingHint.toggle()
                        } label: {
                            Label("Show Hint", systemImage: "questionmark")
                                .labelStyle(.iconOnly)
                        }
                        .foregroundStyle(.primary)
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.circle)
                        .popover(isPresented: $isShowingHint) {
                            VStack {
                                Text("Hint")
                                    .font(.title2)
                                    .bold()
                                Text("Password is ***\(correctPassword)***")
                            }
                                .padding(.horizontal)
                        }
                        .offset(x: 10)
                    }
                    .padding(.trailing)
                
                Button("Enter", action: checkPassword)
                    .buttonStyle(.borderedProminent)
                    .disabled(password.isEmpty)
            }
        }
        .alert("Incorrect Password", isPresented: $isShowingIncorrectPassword) {
            Button("OK") {}
        } message: {
            Text("Check the hint")
        }
    }
    
    func checkPassword() {
        isPasswordFieldFocused = false
        
        guard password == correctPassword else {
            isShowingIncorrectPassword = true
            return
        }
        
        withAnimation {
            navigationController.shownView.next()
        }
    }
}
