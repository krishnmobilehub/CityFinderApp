
import Foundation
import CoreData

class CityItemPresenter: NSObject {
    
    let provider: CityProvider?
    weak private var cityView: CityView?
    
    private var currentPage: Int = 1
    var totalPage: Int = 0
    var totalRecords: Int = 0
    
    private var isProcessing: Bool = false
    
    // MARK: - Initialization & Configuration
    
    init(provider: CityProvider) {
        self.provider = provider
    }
    
    func attachView(view: CityView?) {
        guard let view = view else { return }
        cityView = view
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<Cities> = {
        let fetchRequest = NSFetchRequest<Cities>(entityName:Entity.name)
        let predicate = NSPredicate(format: "%K != %@", Cities.Keys.markedForDeletion.rawValue, NSNumber(value: true))
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Cities.Keys.cityName.rawValue, ascending:true)]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: AppDelegate.shared.persistentContainer.viewContext,
                                                    sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = cityView
        
        do {
            try controller.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")  //TODO: remove before shipping the app
        }
        return controller
    }()
    
    func deleteSearchedCities() {
        AppDelegate.shared.persistentContainer.performBackgroundTask({ (backgroundContext) in
            backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.name)
            let predicate = NSPredicate(format: "%K == %@", Cities.Keys.isSearch.rawValue, NSNumber(value: true))
            deleteFetch.predicate = predicate
            
            do {
                let objects = try backgroundContext.fetch(deleteFetch)
                for object in objects {
                    if let object = object as? NSManagedObject {
                        backgroundContext.delete(object)
                    }
                }
                try backgroundContext.save()
            } catch _ {
                // error handling
            }
        })
    }
    
    func changePredicate(isSearch: Bool) {
        let predicate = NSPredicate(format: "%K == %@", Cities.Keys.isSearch.rawValue, NSNumber(value: isSearch))
        let deletePredicate = NSPredicate(format: "%K != %@", Cities.Keys.markedForDeletion.rawValue, NSNumber(value: true))
        let andPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, deletePredicate])
        
        fetchedResultsController.fetchRequest.sortDescriptors = [NSSortDescriptor(key: Cities.Keys.cityName.rawValue, ascending:true)]
        fetchedResultsController.fetchRequest.predicate = andPredicate
        do {
            try fetchedResultsController.performFetch()
            self.cityView?.fetchedResultsControllerChangedPredicate()
        } catch let error {
            debugPrint(error)
        }
    }
    
    func perFormGetCity(isSearch: Bool = false) {
        guard !isProcessing else {
            return
        }
        self.isProcessing = true
        provider?.performmGetCityWithWith(currentPage: currentPage, completion: { (success, response) in
            if !success {
                self.cityView?.finishWithError(response as? String)
                return
            }
            self.isProcessing = false
            self.changePredicate(isSearch: false)
            self.currentPage += 1
        })
    }
    
    func getSearchedCity(searchCity: String) {
        deleteSearchedCities()
        provider?.performGetSearchedCityWith(cityName: searchCity, completion: { (success, response) in
            self.changePredicate(isSearch: true)
        })
    }
    
}
