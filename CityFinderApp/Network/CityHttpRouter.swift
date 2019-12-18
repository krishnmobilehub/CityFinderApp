
import UIKit
import Foundation
import Alamofire

enum CityHttpRouter: HTTPRouter {
    
    case getCityList(page: String)
    case getSearchedCity(page: String, cityName:String)

    var path: String {
        switch self {
        case .getCityList,
             .getSearchedCity:
            return "city"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        default:
            return .get
        }
    }
    
    var jsonParameters: [String: Any]? {
        switch self {
        case .getCityList(let page):
            return ["page" :page, "include":"country"]
        case .getSearchedCity(let page, let cityName):
            return ["page" :page, "filter[0][name][contains]": cityName, "include":"country"]
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        switch self {
        default:
            return try URLEncoding.queryString.encode(request, with: jsonParameters)
        }
    }
}
