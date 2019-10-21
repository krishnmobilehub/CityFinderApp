
import Foundation
import CoreData


extension Cities {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Cities> {
        return NSFetchRequest<Cities>(entityName: Entity.name)
    }

    @NSManaged public var country: String?
    @NSManaged public var countryId: Int64
    @NSManaged public var cityId: Int64
    @NSManaged public var lat: Double
    @NSManaged public var lng: Double
    @NSManaged public var cityName: String?
    @NSManaged public var localName: String?
    @NSManaged public var markedForDeletion: Bool
    @NSManaged public var isSearch: Bool
}
