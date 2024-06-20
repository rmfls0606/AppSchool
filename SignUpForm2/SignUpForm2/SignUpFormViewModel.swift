//
//  SignUpFormViewModel.swift
//  SignUpForm2
//
//  Created by 이상민 on 6/20/24.
//

import Foundation
import Combine

class SignUpFormViewModel: ObservableObject {
    typealias Available = Result<Bool, Error>
    
    @Published var username: String = ""
    @Published var usernameMessage: String = ""
    @Published var isValid: Bool = false
    @Published var showUpdateDialog: Bool = false
    
    private var authenticationService = AuthenticationService()
    
    private lazy var isUsernameAvailablePublisher: AnyPublisher<Available, Never> = {
        $username
            .debounce(for: 0.5, scheduler: RunLoop.main)
            //같은 문자열이 2번 서버에 보내지지 않도록 필터링

            .removeDuplicates()
            .flatMap { username -> AnyPublisher<Available,Never> in
                self.authenticationService.checkUserNameAvailablePubliser(userName: username)
                    .asResult()
            }
            .receive(on: DispatchQueue.main)
            .print("before share")
            //서버 코드가 들어가있어서 ≈ 공유하는게 좋긴 때문에 share로 선언
            .share()
            .print("share")
            .eraseToAnyPublisher()
    }()
    
    init() {
        isUsernameAvailablePublisher.map { result in
            switch result {
            case .success(let isAvailable):
                return isAvailable
            case .failure(_):
                return false
            }
        }
        .assign(to: &$isValid)
        
        isUsernameAvailablePublisher.map { result in
            switch result {
            case .success(let isAvailable):
                return isAvailable ? "" : "This username is not available."
            case .failure(let error):
                return error.localizedDescription
            }
        }
        .assign(to: &$usernameMessage)
    }
}
