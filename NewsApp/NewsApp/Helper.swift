//
//  Helper.swift
//  NewsApp
//
//  Created by 이상민 on 6/21/24.
//

import Foundation

//에러가 발생했을 때 에러 메시지와 연결시키기 와함
struct APIErrorMessage: Decodable {
    var errorMessage: String
    var errorCode: String
}

enum APIError: LocalizedError {
    case invalidResponse
    case invalidRequestError(String)
    case transportError(Error)
    case validationError(String)
    case decodingError(Error)
    case serverError(statusCode: Int, reason: String? = nil, retryAfter: String? = nil)
    
    var errorDescription: String? {
        switch self {
        case .invalidRequestError(let message):
            return "Invalid request: \(message)"
        case .transportError(let error):
            return "Transport error: \(error)"
        case .invalidResponse:
            return "Invalid response"
        case .validationError(let reason):
            return "Validation error: \(reason)"
        case .decodingError:
            return "The server returned data in an unexpected format. Try updating the app."
        case .serverError(let statusCode, let reason, let retryAfter):
            return "Server error with code \(statusCode), reason: \(reason ?? "no reason given"), retry after: \(retryAfter ?? "no retry after provided")"
        }
    }
}
