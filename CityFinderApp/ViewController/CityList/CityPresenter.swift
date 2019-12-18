
import UIKit
import CoreData
class CityPresenter: NSObject {

    let provider: CityProvider
    weak private var cityView: CityView?
    
    var currentPage: Int = 0
    var totalPage: Int = 0
    var totalRecords: Int = 0
    
    var currentPageSearched: Int = 0
    var totalPageSearched: Int = 0
    var totalRecordsSearched: Int = 0

    // MARK: - Initialization & Configuration
    init(provider: CityProvider) {
        self.provider = provider
    }

    func attachView(view: CityView?) {
        guard let view = view else { return }
        cityView = view
    }
    
    
    func perFormGetCityWith(cityData: CityData) {
        provider.performEnterCodeWith(cityData: cityData, successHandler: { (cityData) in
            self.totalPage = cityData.totalPage ?? 0
            self.totalRecords = cityData.totalRecords ?? 0
            self.cityView?.finishPerformingGetCityListsSuccess(items:cityData)
        }) { (error) in
            self.cityView?.finishPerformingGetCityListsWithError(error: error.localizedDescription)
        }
    }
    
    func perFormGetCounrtyWith(cityData: CityData) {
        provider.performEnterCodeWith(cityData: cityData, successHandler: { (cityData) in
            self.totalPageSearched = cityData.totalPage ?? 0
            self.totalRecordsSearched = cityData.totalRecords ?? 0
            self.cityView?.finishPerformingGetCityListsSuccess(items:cityData)
        }) { (error) in
            self.cityView?.finishPerformingGetCityListsWithError(error: error.localizedDescription)
        }
    }
}
