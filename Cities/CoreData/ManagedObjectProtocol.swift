
import Foundation
import CoreData

protocol ManagedObjectProtocol {}

extension ManagedObjectProtocol where Self: NSManagedObject {
    
    static var entityName: String {
        return entity().name ?? ""
    }
    
    static func insert(into context: NSManagedObjectContext) -> Self {
        return Self(context: context)
    }
    
    static func saveContext(_ context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                debugPrint("context failed with Error: \(error)")
            }
        }
    }
 
    static func findAll(in context: NSManagedObjectContext, with predicate: NSPredicate? = nil) -> [Self] {
        
        let request = fetchRequest()
        if let predicate = predicate {
            request.predicate = predicate
        }
        
        return results(in: context, from: request)
    }
    
    static func findAll(in context: NSManagedObjectContext, sortedByKey sortKey: String? = nil, ascending: Bool = true) -> [Self] {
        
        let request = fetchRequest()
        
        if let sortKey = sortKey {
            request.sortDescriptors = [NSSortDescriptor(key: sortKey, ascending: ascending)]
        }
        
        return results(in: context, from: request)
    }
    
    private static func results(in context: NSManagedObjectContext, from request: NSFetchRequest<NSFetchRequestResult>) -> [Self] {
        do {
            let results = try context.fetch(request) as? [Self]
            return results ?? []
        } catch {
            debugPrint("No objects found for: \(entityName)")
            return []
        }
    }
}
