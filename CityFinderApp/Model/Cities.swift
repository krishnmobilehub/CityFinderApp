
import Foundation
import CoreData

@objc(Cities)
public class Cities: NSManagedObject, ManagedObjectProtocol {
    public enum Keys: String {
        case cityId
        case markedForDeletion
        case cityName
        case isSearch
    }
    
    override public func awakeFromInsert() {
        super.awakeFromInsert()
    }
    
    class func getCity(forCityId cityId:String, inContext: NSManagedObjectContext) -> Cities? {
        let fetchRequest: NSFetchRequest<Cities> = Cities.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", Cities.Keys.cityId.rawValue, cityId)
        do {
            let fetchedResults = try inContext.fetch(fetchRequest)
            if let aLocation = fetchedResults.first {
                return aLocation
            }
            return nil
        } catch {
            return nil
        }
    }
}

extension Cities {
    
    // MARK: Data Loading
    public class func getCities(fromData:[Any], inContext:NSManagedObjectContext, isSearch: Bool) {
        let existingLocations = self.findAll(in: inContext)
        // need to mark existing locations
        existingLocations.forEach {
            $0.markedForDeletion = true
        }
        var count = 0
        var predicate: NSPredicate
        
        for aNode in fromData {
            guard
                let aDict = aNode as? Dictionary<String, Any>,
                let cityId = aDict["id"] as? Int64
                else {
                    continue
            }
            predicate = NSPredicate(format: "%K == %d", Cities.Keys.cityId.rawValue, cityId)
            let filteredLocation = existingLocations.filter {predicate.evaluate(with: $0)}
            var aCity = filteredLocation.last
            
            if aCity == nil {
                aCity = Cities(context: inContext)
                aCity?.cityId = cityId
            } else {
                if isSearch {
                    aCity?.markedForDeletion = true
                }
            }
            
            do {
                try aCity?.updateCity(withData: aDict)
                aCity?.markedForDeletion = false
                
            } catch {
                debugPrint(error)
                aCity?.markedForDeletion = true
            }
            aCity?.isSearch = isSearch
            count += 1
            if count > 5 {
                inContext.saveContext()
                count = 0
            }
        }  //end for
        
        inContext.saveContext()
    }
    
    func updateCity(withData data:[String:Any]) throws {
        guard
            let id = data["id"] as? Int64
            else {
                throw NSError(domain: "City Data parsing", code: 0, userInfo: nil)
        }

        self.cityId = id
        self.cityName = data["name"] as? String
        if let country = data["country"] as? [String: Any] {
            self.country = country["name"] as? String
        }
        self.localName = data["local_name"] as? String
        self.lat = data["lat"] as? Double ?? 0.0
        self.lng = data["lng"] as? Double ?? 0.0
    }
}
