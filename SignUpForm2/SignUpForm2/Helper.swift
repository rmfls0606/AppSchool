//
//  Helper.swift
//  SignUpForm2
//
//  Created by 이상민 on 6/20/24.
//

import Foundation
import Combine

struct UserNameAvailableMessage: Codable{
    var isAvailable: Bool
    var userName: String
}

//에러가 발생했을 때 에러 메시지와 연결시키기 와함
struct APIErrorMessage: Decodable{
    var error: Bool
    var resaon: String
}

enum APIError: LocalizedError{
    case invalidResponse
}

extension Publisher{
    func asResult() -> AnyPublisher<Result<Output, Failure>, Never>{
        self.map(Result.success)
            .catch{ error in
                Just(.failure(error))
            }
            //감싸진 흐름을 다시 흘려보낸다.
            .eraseToAnyPublisher()
    }
}
