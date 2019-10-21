
import Foundation
import Alamofire

class NetworkManager {
    
    static let networkUnavailableCode: Double = 1000
    
    public static let networkQueue = DispatchQueue(label: "\(String(describing: Bundle.main.bundleIdentifier)).networking-queue", attributes: .concurrent)
    
    static func makeRequest(_ urlRequest: URLRequestConvertible, showLog: Bool = false, completion: @escaping (Result) -> ()) {
        Alamofire.request(urlRequest).responseJSON { responseObject in
            switch responseObject.result {
            case .success(let value):
                debugPrint("URL: \(urlRequest.urlRequest?.url?.absoluteString ?? "")")
                
                if (showLog) {
                    debugPrint("Response: \(value)")
                }
                
                if let error = error(fromResponseObject: responseObject) {
                    completion(.failure(error))
                } else {
                    completion(.success(value))
                }
            case .failure(let error):
                completion(.failure(generateError(from: error, with: responseObject)))
            }
        }
    }
    
    static func error(fromResponseObject responseObject: DataResponse<Any>) -> Error? {
        if let statusCode = responseObject.response?.statusCode {
            switch statusCode {
            case 200...300: return nil
            default:
                if let result = responseObject.result.value as? [String: Any],
                    let errorMessage = result["error"] as? String {
                    if let code = result["code"] as? Double {
                        return NetworkError.error(code: code, message: errorMessage)
                    } else {
                        return NetworkError.errorString(errorMessage)
                    }
                }
            }
        }
        return NetworkError.errorString(Errors.genericError)
    }
    
    static func generateError(from error: Error, with responseObject: DataResponse<Any>) -> Error {
        if let statusCode = responseObject.response?.statusCode {
            if let data = responseObject.data, let jsonString = String(data: data, encoding: .utf8) {
                return NetworkError.error(code: Double(statusCode), message: jsonString)
            }
        } else {
            let code = (error as NSError).code
            switch code {
            case NSURLErrorNotConnectedToInternet, NSURLErrorCannotConnectToHost, NSURLErrorCannotFindHost:
                return NetworkError.error(code: networkUnavailableCode, message: Errors.networkUnreachableError)
            default:
                return NetworkError.errorString(Errors.genericError)
            }
        }
        return NetworkError.errorString(Errors.genericError)
    }
}

enum Result {
    case success(Any)
    case failure(Error)
    
    var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    var isFailure: Bool {
        return !isSuccess
    }
    
    var value: Any? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }
    
    var error: Error? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
}

enum NetworkError: CitiesLocalizedError {
    
    case errorString(String)
    case error(code: Double?, message: String)
    case generic
    
    var errorDescription: String? {
        switch self {
        case .errorString(let errorMessage): return errorMessage
        case .error(_,let message): return message
        case .generic: return Errors.genericError
        }
    }
    
    var info: (code: Double?, message: String) {
        switch self {
        case .error(let code, let message):
            return (code, message)
        case .errorString(let errorMessage): return (nil, errorMessage)
        case .generic: return  (nil, Errors.genericError)
        }
    }
    
    var title: String {
        return Alert.title
    }
}

protocol CitiesLocalizedError: LocalizedError {
    var title: String { get }
    var localDescription: String { get }
}

extension CitiesLocalizedError {
    var title: String {
        return ""
    }
    var localDescription : String {
        return ""
    }
}

struct Errors {
    static let genericError = "Something went wrong. Please try again."
    static let networkUnreachableError  = "No internet connection. Please try again later."
}

struct Alert {
    static let title = "Alert"
    static let ok = "Ok"
}

struct Entity {
    static let name = "Cities"
}
