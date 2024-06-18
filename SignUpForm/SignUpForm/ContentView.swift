//
//  ContentView.swift
//  SignUpForm
//
//  Created by 이상민 on 6/18/24.
//

import SwiftUI

class SignUpFormViewModel: ObservableObject{
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var passwordConfirmation: String = ""
    @Published var usernameMessage: String = ""
    @Published var passwordMessage: String = ""
    @Published var isValid: Bool = false
    
    init(){
        $username.map{ $0.count >= 3 }
            .assign(to: &$isValid)
        $username.map{ $0.count >= 3 ? "" : "Username must be at least three characters!" }
            .assign(to: &$usernameMessage)
    }
}


struct ContentView: View {
    @StateObject var viewModel = SignUpFormViewModel()
    
    var body: some View {
        Form{
            //username
            Section(content: {
                TextField("Username", text: $viewModel.username)
                    .autocorrectionDisabled()
            },footer: {
                Text(viewModel.usernameMessage)
                    .foregroundStyle(.red)
            })
            
            //password
            Section{
                SecureField("Password", text: $viewModel.password)
                SecureField("Password", text: $viewModel.passwordConfirmation)
            }footer: {
                Text(viewModel.passwordMessage)
                    .foregroundStyle(.red)
            }
            //Submit
            Section{
                Button("Sign up"){
                    print("Signing up as \(viewModel.username)")
                }
                .disabled(!viewModel.isValid)
            }
        }
    }
}

#Preview {
    ContentView()
}
