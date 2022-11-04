//
//  ApiManager.swift
//  SvmsTask
//
//  Created by Satyaa Akana on 03/11/22.
//


import Foundation

struct APPURL {
    static let BASEURL = "https://api.stackexchange.com"
    static let SITEURL = "/questions"
}

enum HTTPMethod: String {
    case get     = "GET"
    case post    = "POST"
    case put     = "PUT"
    case delete  = "DELETE"
}

// Our Request Protocol
protocol Request {
    var path: String { get }
    var method: HTTPMethod { get }
    var body: Parameters? { get }
    var queryParams: Parameters? { get }
    var headers: [String: String]? { get }
    associatedtype ReturnType: Decodable
}

// Defaults and Helper Methods
extension Request{
    
    // Defaults
    var method: HTTPMethod { return .get }
    var queryParams: Parameters? { return nil }
    var body: Parameters? { return nil }
    var headers: [String: String]? { return ["Content-Type":"application/json"] }
    
   
    /// Serializes an HTTP dictionary to a JSON Data Object
    /// - Parameter params: HTTP Parameters dictionary
    /// - Returns: Encoded JSON
    private func requestBodyFrom(params: Parameters?) -> Data? {
        guard
            let params = params
        else { return nil }
        guard
            let httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        else {
            return nil
        }
        return httpBody
    }
    
    
    
    /// Transforms an Request into a standard URL request
    /// - Parameter baseURL: API Base URL to be used
    /// - Returns: A ready to use URLRequest
    func asURLRequest() -> URLRequest! {
        guard
            var urlComponents = URLComponents(string: APPURL.BASEURL)
        else { return nil }
        urlComponents.path = "\(urlComponents.path)\(path)"
        
        if let queryParams = queryParams {
            urlComponents.queryItems = queryParams.toURLQueryItems()
            debugPrint("queryParams", queryParams)
        }
        guard
            let finalURL = urlComponents.url
        else { return nil }
        debugPrint(finalURL)
        var request = URLRequest(url: finalURL)
        request.httpMethod = method.rawValue
        request.timeoutInterval = Double.infinity
        let httpBody = requestBodyFrom(params: body)
        if body != nil{
            request.httpBody = httpBody
            debugPrint("params", body ?? [:])
        }
        request.allHTTPHeaderFields = headers
        debugPrint("headers",headers ?? [:])
        return request
    }
}

protocol APIService{
    func fetch<T: Decodable>(request: URLRequest, completion: @escaping (Result<T, NetworkRequestError>) -> Void)
}

// MARK: - APIHANDLER
///  Dispatches an URLRequest and returns a publisher
/// - Parameter request: URLRequest
/// - Returns: A publisher with the provided decoded data or an error
///
final class APIServiceImpl: APIService{
    private init(){}
    static let shared:APIServiceImpl = {
        let instance = APIServiceImpl()
        return instance
    }()
    
   
    func fetch<T>(request: URLRequest, completion: @escaping (Result<T, NetworkRequestError>) -> Void) where T : Decodable {
        guard
            Reachability.isConnectedToNetwork()
        else {
            completion(.failure(NetworkRequestError.internetNotAvailable))
            return
        }
        let sessionConfig = URLSessionConfiguration.default
        URLSession(configuration: sessionConfig).dataTask(with: request) { [self] (data, response, error) in
            
            if let error = error{
                let err = (error as? URLError)?.code
                if  err == .cannotFindHost {
                completion(.failure(NetworkRequestError.errorMessage("A server with the specified hostname could not be found.")))
                }else if err == .timedOut {
                    completion(.failure(NetworkRequestError.errorMessage("The request timed out., please try again")))
                }else{
                    completion(.failure(NetworkRequestError.serverError))
                }
                return
            }
            if let response = response as? HTTPURLResponse,
               !(200...299).contains(response.statusCode){
                completion(.failure(self.httpError(response.statusCode)))
                return
            }
          
                guard
                    let data = data
                else {
                    completion(.failure(NetworkRequestError.notFound))
                    return
                }
                let dataString = String(data: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) ?? ""
                NSLog(dataString)
                do{
                    let result = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(result))
                }catch{
                    print(error)
                    completion(.failure(handleError(error)))
                }
            
        }.resume()
    }
    
    /// Parses a HTTP StatusCode and returns a proper error
    /// - Parameter statusCode: HTTP status code
    /// - Returns: Mapped Error
    private func httpError(_ statusCode: Int) -> NetworkRequestError {
        switch statusCode {
        case 400: return .badRequest
        case 401: return .unauthorized
        case 403: return .forbidden
        case 404: return .notFound
        case 402, 405...499: return .error4xx(statusCode)
        case 500: return .serverError
        case 501...599: return .error5xx(statusCode)
        default: return .unknownError
        }
    }
    
    /// Parses URLSession Publisher errors and return proper ones
    /// - Parameter error: URLSession publisher error
    /// - Returns: Readable NetworkRequestError
    private func handleError(_ error: Error) -> NetworkRequestError {
        switch error {
        case is Swift.DecodingError:
            return .decodingError
        case let urlError as URLError:
            return .urlSessionFailed(urlError)
        case let error as NetworkRequestError:
            return error
        default:
            return .unknownError
        }
    }
    
}


extension Encodable {
    var asDictionary: [String: Any] {
        guard
            let data = try? JSONEncoder().encode(self)
        else { return [:] }
        
        guard
            let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
        else {
            return [:]
        }
        return dictionary
    }
}


public typealias Parameters = [String:Any]

