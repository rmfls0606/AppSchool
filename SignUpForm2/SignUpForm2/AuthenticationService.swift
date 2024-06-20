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
        guard let url = URL(string: "http://127.0.0.1:8080/isUserNameAvailable?userName=\(userName)") else {
            return Fail(error: APIError.invalidRequestError("URL Invalid")).eraseToAnyPublisher()
        }
        
        let dataTaskPublisher = URLSession.shared.dataTaskPublisher(for: url)
            .mapError{ error -> Error in
                return APIError.transportError(error)
            }
            .tryMap{ (data, response) -> (data: Data, response: URLResponse) in
                print("Received response from server, now checking status code")
                
                guard let urlResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                if (200..<300) ~= urlResponse.statusCode{
                    
                }else{
                    let decoder = JSONDecoder()
                    let apiError = try decoder.decode(APIErrorMessage.self, from: data)
                    
                    if urlResponse.statusCode == 400{
                        throw APIError.validationError(apiError.resaon)
                    }
                    
                    if (500..<600) ~= urlResponse.statusCode{
                        let retryAfter = urlResponse.value(forHTTPHeaderField: "Retry-After")
                        throw APIError.serverError(statusCode: urlResponse.statusCode, reason: apiError.resaon, retryAfter: retryAfter)
                    }
                }
                return (data, response)
            }
        
        return dataTaskPublisher
            .retry(10, withDelay: 3){ error in
                if case APIError.serverError = error {
                    return true
                }
                return false
            }
            .map(\.data)
//            .decode(type: UserNameAvailableMessage.self, decoder: JSONDecoder())
            .tryMap{ data -> UserNameAvailableMessage in
                let decoder = JSONDecoder()
                do{
                    return try decoder.decode(UserNameAvailableMessage.self, from: data)
                }catch{
                    throw APIError.decodingError(error)
                }
            }
            .map(\.isAvailable)
            .eraseToAnyPublisher()
    }
}
