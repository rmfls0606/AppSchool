//
//  Publisher+Retry.swift
//  SignUpForm2
//
//  Created by 이상민 on 6/20/24.
//

import Foundation
import Combine

extension Publisher {
    func retry<T, E> (_ retryCount: Int, withBackoff initalBackoff: Int, condition: ((E) -> Bool)? = nil) -> Publishers.TryCatch<Self, AnyPublisher<T, E>> where T == Self.Output, E == Self.Failure {
        return self.tryCatch { error -> AnyPublisher<T, E> in
            if condition?(error) == true {
                var backOff = initalBackoff
                return Just(Void())
                //                    .delay(for: .init(integerLiteral: delay), scheduler: DispatchQueue.global())
                    .flatMap { _ -> AnyPublisher<T, E> in
                        let result = Just(Void())
                            .delay(for: .init(integerLiteral: initalBackoff), scheduler: DispatchQueue.global())
                            .flatMap{ _ in return self}
                        backOff = backOff * 2
                        return result.eraseToAnyPublisher()
                    }
                    .retry(retryCount - 1)
                    .eraseToAnyPublisher()
            } else {
                throw error
            }
        }
    }
}
