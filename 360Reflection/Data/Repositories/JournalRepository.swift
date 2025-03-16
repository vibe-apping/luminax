import Foundation
import CoreData
import Combine

class JournalRepository: Repository {
    typealias Entity = JournalEntry
    typealias ID = UUID
    
    private let coreDataManager: CoreDataManager
    
    init(coreDataManager: CoreDataManager = .shared) {
        self.coreDataManager = coreDataManager
    }
    
    func getAll() -> AnyPublisher<[JournalEntry], Error> {
        return Future<[JournalEntry], Error> { promise in
            let sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            let entries = self.coreDataManager.fetch(JournalEntry.self, sortDescriptors: sortDescriptors)
            promise(.success(entries))
        }.eraseToAnyPublisher()
    }
    
    func getById(_ id: UUID) -> AnyPublisher<JournalEntry?, Error> {
        return Future<JournalEntry?, Error> { promise in
            let predicate = NSPredicate(format: "id == %@", id as CVarArg)
            let entries = self.coreDataManager.fetch(JournalEntry.self, predicate: predicate)
            promise(.success(entries.first))
        }.eraseToAnyPublisher()
    }
    
    func create(_ entity: JournalEntry) -> AnyPublisher<JournalEntry, Error> {
        return Future<JournalEntry, Error> { promise in
            // If the entity already has a context, use it as is
            if entity.managedObjectContext != nil {
                do {
                    try entity.managedObjectContext?.save()
                    promise(.success(entity))
                } catch {
                    promise(.failure(error))
                }
            } else {
                // Otherwise, create a new managed object
                let newEntry = self.coreDataManager.create(JournalEntry.self)
                newEntry.id = entity.id
                newEntry.title = entity.title
                newEntry.content = entity.content
                newEntry.createdAt = entity.createdAt
                newEntry.updatedAt = entity.updatedAt
                newEntry.mood = entity.mood
                
                self.coreDataManager.saveContext()
                promise(.success(newEntry))
            }
        }.eraseToAnyPublisher()
    }
    
    func update(_ entity: JournalEntry) -> AnyPublisher<JournalEntry, Error> {
        return Future<JournalEntry, Error> { promise in
            if let id = entity.id {
                let predicate = NSPredicate(format: "id == %@", id as CVarArg)
                let entries = self.coreDataManager.fetch(JournalEntry.self, predicate: predicate)
                
                if let existingEntry = entries.first {
                    existingEntry.title = entity.title
                    existingEntry.content = entity.content
                    existingEntry.updatedAt = Date()
                    existingEntry.mood = entity.mood
                    
                    self.coreDataManager.saveContext()
                    promise(.success(existingEntry))
                } else {
                    promise(.failure(NSError(domain: "JournalRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Journal entry not found"])))
                }
            } else {
                promise(.failure(NSError(domain: "JournalRepository", code: 400, userInfo: [NSLocalizedDescriptionKey: "Journal entry ID is missing"])))
            }
        }.eraseToAnyPublisher()
    }
    
    func delete(_ id: UUID) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { promise in
            let predicate = NSPredicate(format: "id == %@", id as CVarArg)
            let entries = self.coreDataManager.fetch(JournalEntry.self, predicate: predicate)
            
            if let entryToDelete = entries.first {
                self.coreDataManager.delete(entryToDelete)
                promise(.success(true))
            } else {
                promise(.success(false))
            }
        }.eraseToAnyPublisher()
    }
    
    // Additional methods specific to JournalEntry
    
    func getEntriesByDateRange(start: Date, end: Date) -> AnyPublisher<[JournalEntry], Error> {
        return Future<[JournalEntry], Error> { promise in
            let predicate = NSPredicate(format: "createdAt >= %@ AND createdAt <= %@", start as NSDate, end as NSDate)
            let sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            let entries = self.coreDataManager.fetch(JournalEntry.self, predicate: predicate, sortDescriptors: sortDescriptors)
            promise(.success(entries))
        }.eraseToAnyPublisher()
    }
    
    func getEntriesByMood(_ mood: Int16) -> AnyPublisher<[JournalEntry], Error> {
        return Future<[JournalEntry], Error> { promise in
            let predicate = NSPredicate(format: "mood == %d", mood)
            let sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            let entries = self.coreDataManager.fetch(JournalEntry.self, predicate: predicate, sortDescriptors: sortDescriptors)
            promise(.success(entries))
        }.eraseToAnyPublisher()
    }
}
