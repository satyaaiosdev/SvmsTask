//
//  NetworkError.swift
//  SvmsTask
//
//  Created by Satyaa Akana on 03/11/22.

import Foundation

enum NetworkRequestError: LocalizedError, Equatable {
    case internetNotAvailable
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case error4xx(_ code: Int)
    case serverError
    case error5xx(_ code: Int)
    case decodingError
    case urlSessionFailed(_ error: URLError)
    case unknownError
    case errorMessage(_ message: String)
    var localizedString: String{
        switch self {
        case .internetNotAvailable:
            return "No Internet Connection. Please check your internet connection."
        case .badRequest:
            return "Data not Found" //"Failed to encode request parameters"
        case .unauthorized:
            return "Authenticatioon failed"
        case .forbidden:
            return "URL forbidden"
        case .notFound:
            return "Data not Found"
        case .error4xx(let statusCode):
            return "Error with the request, unexpected status code: \(statusCode)"
        case .serverError:
            return "Sorry, couldn't reach our server."
        case .error5xx(let statusCode):
            return "Service Unavailable, unexpected status code: \(statusCode)"
        case .decodingError:
            return "Something went wrong. Please try again after sometime."
        case .urlSessionFailed(let session):
            return "\(session)"
        case .unknownError:
            return ""
        case .errorMessage(let message):
            return message
        }
    }
}
