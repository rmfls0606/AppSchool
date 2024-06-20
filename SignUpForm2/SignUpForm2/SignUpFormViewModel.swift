//
//  SignUpFormViewModel.swift
//  SignUpForm2
//
//  Created by 이상민 on 6/20/24.
//
//
//  SignUpFormViewModel.swift
//  SignUpForm2
//
//  Created by Jungman Bae on 6/20/24.
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
            .removeDuplicates()
            .flatMap { username -> AnyPublisher<Available,Never> in
                self.authenticationService.checkUserNameAvailablePubliser(userName: username)
                    .asResult()
            }
            .receive(on: DispatchQueue.main)
            .print("before share")
            .share()
            .print("share")
            .eraseToAnyPublisher()
    }()
    
    init() {
        isUsernameAvailablePublisher.map { result in
            switch result {
            case .success(let isAvailable):
                return isAvailable
            case .failure(let error):
                if case APIError.transportError(_) = error {
                    return true
                }
                return false
            }
        }
        .assign(to: &$isValid)
        
        isUsernameAvailablePublisher.map { result in
            switch result {
            case .success(let isAvailable):
                return isAvailable ? "" : "This username is not available."
            case .failure(let error):
                if case APIError.transportError(_) = error {
                    return ""
                }
                else if case APIError.validationError(let reason) = error {
                    return reason
                }
                else if case APIError.serverError(statusCode: _, reason: let reason, retryAfter: _) = error {
                    return reason ?? "Server error"
                }
                return error.localizedDescription
            }
        }
        .assign(to: &$usernameMessage)
        
        isUsernameAvailablePublisher.map { result in
            if case .failure(let error) = result {
                if case APIError.decodingError = error {
                    return true
                }
            }
            return false
        }
        .assign(to: &$showUpdateDialog)
    }
}
