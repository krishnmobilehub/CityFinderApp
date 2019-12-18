
import Foundation
import CoreData

typealias CompletionBlock = (_ success: Bool, _ response: Any?) -> Void

class CityProvider {

    func performmGetCityWithWith(currentPage: Int, completion: @escaping(CompletionBlock)) {
        NetworkManager.makeRequest(CityHttpRouter.getCityList(page: "\(currentPage)")) { (result) in
            switch result {
            case .success(let value):
                guard
                    let result = value as? [String:Any],
                    let data = result["data"] as? [String: Any],
                    let items = data["items"] as? [Any]
                    else {
                        completion(false, NetworkError.errorString("City parsing error"))
                        return
                }
                AppDelegate.shared.persistentContainer.performBackgroundTask({ (backgroundContext) in
                    backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

                    Cities.getCities(fromData: items, inContext: backgroundContext, isSearch: false)
                    DispatchQueue.main.async {
                        completion(true, items)
                    }
                })
            case .failure(let error):
                completion(false, error.localizedDescription)
                print(error.localizedDescription)
            }
        }
    }
    
    func performGetSearchedCityWith(cityName: String, completion: @escaping(CompletionBlock)) {
        NetworkManager.makeRequest(CityHttpRouter.getSearchedCity(page: "1", cityName: cityName)) { (result) in
            switch result {
            case .success(let value):
                guard
                    let result = value as? [String:Any],
                    let data = result["data"] as? [String: Any],
                    let items = data["items"] as? [Any]
                    else {
                        completion(false, NetworkError.errorString("Locations parsing error"))
                        return
                }
                AppDelegate.shared.persistentContainer.performBackgroundTask({ (backgroundContext) in
                    backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                    
                    Cities.getCities(fromData: items, inContext: backgroundContext, isSearch: true)
                    DispatchQueue.main.async {
                        completion(true, items)
                    }
                })
            case .failure(let error):
                completion(false, error.localizedDescription)
                print(error.localizedDescription)
            }
        }
    }
    
    
}
