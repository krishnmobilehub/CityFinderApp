
import Foundation
import CoreData

protocol CityView: NSFetchedResultsControllerDelegate {
    func fetchedResultsControllerChangedPredicate()
    func finishWithError(_ error: String?) 
}
