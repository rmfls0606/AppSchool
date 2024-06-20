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
        //Publisher의 모든 출력 값을 Result.success로 매핑합니다.
        //즉, 성공적인 값을 Result<Output, Failure>.success 타입으로 래핑합니다.
        //예를 들어, Output이 Int라면 Result.success(값)이 됩니다.
        self.map(Result.success)
            //만약 Publisher가 오류를 발생시키면, 이 오류를 잡아서(catch) Result.failure로 변환합니다.
            //Just(.failure(error))는 하나의 요소를 발행하는 Publisher를 반환하는데, 이 요소는 Result<Output, Failure>.failure 타입입니다.
            .catch{ error in
                Just(.failure(error))
            }
            //감싸진 흐름을 다시 흘려보낸다.
            .eraseToAnyPublisher()
    }
}
