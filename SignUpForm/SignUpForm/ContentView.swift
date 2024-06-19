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
    
    @Published var isUserNameAvailable: Bool = false
    
    private let authenticationService = AuthenticationService()
    
    private var cancellables: Set<AnyCancellable> = []
    
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
        Publishers.CombineLatest3(isPasswordEmptyPublisher, $isUserNameAvailable, isPassworMathchingPublisher)
            .map{ $0 && $1 && $2}
            .eraseToAnyPublisher()
    }()
    
    private lazy var isFormValidPublisher: AnyPublisher<Bool, Never> = {
        Publishers.CombineLatest(isUsernameLengthValidPublisher, isPasswordValidPublisher)
            .map{ $0 && $1 }
            .eraseToAnyPublisher()
    }()
    
    func checkUserNameAvailable(_ userName: String){
        authenticationService.checkUserNameAvailableWithClousre(userName: userName) { [weak self] result in
            DispatchQueue.main.async{
                switch result{
                case .success(let isAvailable):
                    self?.isUserNameAvailable = isAvailable
                case .failure(let error):
                    print("error: \(error)")
                    self?.isUserNameAvailable = false
                }
            }
        }
    }
    
    init(){
        //입력이 멈췃을 때 0.5초마다 메인쓰레드에서 보내라
        $username.debounce(for: 0.5, scheduler: DispatchQueue.main).sink { [weak self] userName in
            self?.checkUserNameAvailable(userName)
        }
        .store(in: &cancellables)
        
        isUsernameLengthValidPublisher
            .assign(to: &$isValid)
        
        Publishers.CombineLatest(isUsernameLengthValidPublisher, $isUserNameAvailable).map{ isUsernameLengthValid, isUserNameAvailable in
            if !isUsernameLengthValid{
                return "Username must be at least three characters!"
            }else if !isUserNameAvailable{
                return "This username is already taken"
            }
            return ""
        }
        .assign(to: &$usernameMessage)
        
//        $username.map{ $0.count >= 3 ? "" : "Username must be at least three characters!" }
//            .assign(to: &$usernameMessage)
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
