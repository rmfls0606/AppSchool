//
//  ContentView.swift
//  SignUpForm
//
//  Created by 이상민 on 6/18/24.
//

import SwiftUI
import Combine

class SignUpFormViewModel: ObservableObject{
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var passwordConfirmation: String = ""
    @Published var usernameMessage: String = ""
    @Published var passwordMessage: String = ""
    @Published var isValid: Bool = false
    
    private lazy var isUsernameLengthValidPublisher: AnyPublisher<Bool, Never> = {
        $username.map{ $0.count >= 3}.eraseToAnyPublisher()
    }()
    
    private lazy var isPasswordEmptyPublisher: AnyPublisher<Bool, Never> = {
        $password.map(\.isEmpty).eraseToAnyPublisher()
    }()
    
    private lazy var isPassworMathchingPublisher: AnyPublisher<Bool, Never> = {
        Publishers.CombineLatest($password, $passwordConfirmation)
            .map(==)
            .eraseToAnyPublisher()
    }()
    
    private lazy var isPasswordValidPublisher: AnyPublisher<Bool, Never> = {
        Publishers.CombineLatest(isPasswordEmptyPublisher, isPassworMathchingPublisher)
            .map{ !$0 && $1 }
            .eraseToAnyPublisher()
    }()
    
    private lazy var isFormValidPublisher: AnyPublisher<Bool, Never> = {
        Publishers.CombineLatest(isUsernameLengthValidPublisher, isPasswordValidPublisher)
            .map{ $0 && $1 }
            .eraseToAnyPublisher()
    }()
    
    init(){
        isUsernameLengthValidPublisher
            .assign(to: &$isValid)
        $username.map{ $0.count >= 3 ? "" : "Username must be at least three characters!" }
            .assign(to: &$usernameMessage)
        Publishers.CombineLatest(isPasswordEmptyPublisher, isPassworMathchingPublisher)
            .map{ isPasswordEmpty, isPasswordMatching in
                if isPasswordEmpty {
                    return "Password must not be empty"
                }else if !isPasswordMatching{
                    return "Passwords do not match"
                }
                return ""
            }
            .assign(to: &$passwordMessage)
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
