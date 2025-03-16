import Foundation
import Combine

protocol Repository {
    associatedtype Entity
    associatedtype ID
    
    func getAll() -> AnyPublisher<[Entity], Error>
    func getById(_ id: ID) -> AnyPublisher<Entity?, Error>
    func create(_ entity: Entity) -> AnyPublisher<Entity, Error>
    func update(_ entity: Entity) -> AnyPublisher<Entity, Error>
    func delete(_ id: ID) -> AnyPublisher<Bool, Error>
}
