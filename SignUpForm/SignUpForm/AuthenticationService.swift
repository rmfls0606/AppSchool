//
//  AuthenticationService.swift
//  SignUpForm
//
//  Created by 이상민 on 6/19/24.
//

import Foundation
import Combine

struct UserNameAvailableMessage: Codable{
    var isAvailable: Bool
    var userName: String
}

enum NetworkError: Error{
    case transportError(Error)
    case serverError(statusCode: Int)
    case noData
    case decodingError(Error)
    case encodingError(Error)
}

enum APIError: LocalizedError{
    case InvalidRequest
}


class AuthenticationService{
    func checkUserNameAvailableNaive(userName: String) -> AnyPublisher<Bool, Never>{
        guard let url = URL(string: "http://127.0.0.1:8080/isUserNameAvailable?userName=\(userName)") else{
            return Just(false).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: UserNameAvailableMessage.self, decoder: JSONDecoder())
            .map(\.isAvailable)
//            .map{ data, response in
//                do{
//                    let decoder = JSONDecoder()
//                    let userAvailableMessage = try decoder.decode(UserNameAvailableMessage.self, from: data)
//                    return userAvailableMessage.isAvailable
//                }catch{
//                    return false
//                }
//            }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
    
    
    func checkUserNameAvailableWithClousre(userName: String, completion: @escaping (Result<Bool, NetworkError>) -> Void){
        let url = URL(string: "http://127.0.0.1:8080/isUserNameAvailable?userName=\(userName)")!
        
        let task = URLSession.shared.dataTask(with: url){ data, response, error in
            if let error = error{
                completion(.failure(.transportError(error)))
                return
            }
            
            if let response = response as? HTTPURLResponse,
               !(200..<300).contains(response.statusCode){
                completion(.failure(.serverError(statusCode: response.statusCode)))
                return
            }
            
            guard let data = data else{
                completion(.failure(.noData))
                return
            }
            
            do{
                let decoder = JSONDecoder()
                let userAvailableMessage = try decoder.decode(UserNameAvailableMessage.self, from: data)
                completion(.success(userAvailableMessage.isAvailable))
            }catch{
                completion(.failure(.decodingError(error)))
            }
        }
        
        task.resume()
    }
}
