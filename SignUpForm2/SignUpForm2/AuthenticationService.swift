//
//  AuthenticationService.swift
//  SignUpForm2
//
//  Created by 이상민 on 6/20/24.
//

import Foundation
import Combine

struct AuthenticationService{
    func checkUserNameAvailablePubliser(userName: String) -> AnyPublisher<Bool, Error>{
        return Fail(error: APIError.invalidResponse).eraseToAnyPublisher()
    }
}
