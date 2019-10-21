
import Foundation
import CoreData

private let appContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: Entity.name)
    return container
}()

public func createPersistentContainer(completion: @escaping (NSPersistentContainer) -> ()) {
    appContainer.loadPersistentStores { _, error in
        if error == nil {
            appContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            appContainer.viewContext.undoManager = nil
            appContainer.viewContext.automaticallyMergesChangesFromParent = true
            debugPrint(appContainer.persistentStoreDescriptions)
            let path = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
            debugPrint("\(path)")
            completion(appContainer)
        } else {
            fatalError("Unresolved error \(String(describing: error))")
        }
    }
}

extension NSManagedObjectContext {
    
    public func saveOrRollback() -> Bool {
        do {
            try save()
            return true
        } catch let error {
            rollback()
            debugPrint("----->>  Rollback Error: \(error)")
            return false
        }
    }
    
    func saveContext() {
        _ = saveOrRollback()
    }
}
