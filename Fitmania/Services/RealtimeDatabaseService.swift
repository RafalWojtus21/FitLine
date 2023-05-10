//
//  RealtimeDatabaseService.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 24/04/2023.
//

import Foundation
import RxSwift
import FirebaseFirestore
import FirebaseDatabase
import FirebaseDatabaseSwift

protocol HasRealtimeDatabaseService {
    var realtimeDatabaseService: RealtimeDatabaseService { get }
}

protocol RealtimeDatabaseService {
    var database: Database { get }
    func save<T: Encodable>(_ object: T, at databaseReference: DatabaseReference, encoder: JSONEncoder?) -> Completable
    func fetchDataSingle<T: Decodable>(_ objectType: T.Type, from databaseReference: DatabaseReference, decoder: JSONDecoder?) -> Single<T>
    func fetchDataObservable<T: Decodable>(_ objectType: T.Type, from databaseReference: DatabaseReference, decoder: JSONDecoder?) -> Observable<T>
    func delete(from databaseReference: DatabaseReference) -> Completable
    func childRemovedObservable<T: Decodable>(_ objectType: T.Type, from databaseReference: DatabaseReference, decoder: JSONDecoder?) -> Observable<T>
    func childAddedObservable<T: Decodable>(_ objectType: T.Type, from databaseReference: DatabaseReference, decoder: JSONDecoder?) -> Observable<T> 
}

final class RealtimeDatabaseServiceImpl: RealtimeDatabaseService {
    
    // MARK: - Properties

    let bag = DisposeBag()
    let database = Database.database(url: Config.realtimeDatabaseUrl)
    let jsonEncoder = JSONEncoder()
    let jsonDecoder = JSONDecoder()
    
    // MARK: Public Implementation

    func save<T: Encodable>(_ object: T, at databaseReference: DatabaseReference, encoder: JSONEncoder?) -> Completable {
        return Completable.create { completable in
            do {
                let encoder = encoder ?? self.jsonEncoder
                let objectData = try encoder.encode(object)
                let dictionary = try JSONSerialization.jsonObject(with: objectData, options: [])
                databaseReference.setValue(dictionary) { error, _ in
                    if let error = error {
                        completable(.error(error))
                    } else {
                        completable(.completed)
                    }
                }
            } catch {
                completable(.error(error))
            }
            return Disposables.create()
        }
    }
    
    func delete(from databaseReference: DatabaseReference) -> Completable {
        return Completable.create { completable in
            databaseReference.removeValue { error, _ in
                if let error = error {
                    completable(.error(error))
                } else {
                    completable(.completed)
                }
            }
            return Disposables.create()
        }
    }
    
    func fetchDataSingle<T: Decodable>(_ objectType: T.Type, from databaseReference: DatabaseReference, decoder: JSONDecoder?) -> Single<T> {
        return Single.create { single in
            databaseReference.observe(.value, with: { snapshot in
                guard let value = snapshot.value as? [String: Any] else {
                    return single(.failure(DatabaseError.noData))
                }
                do {
                    let object = try self.decodeObject(objectType, from: value, decoder: decoder)
                    single(.success(object))
                } catch {
                    single(.failure(error))
                }
            })
            return Disposables.create()
        }
    }
    
    func fetchDataObservable<T: Decodable>(_ objectType: T.Type, from databaseReference: DatabaseReference, decoder: JSONDecoder?) -> Observable<T> {
        return Observable.create { observer in
            databaseReference.observe(.childAdded) { snapshot in
                guard let value = snapshot.value else {
                    observer.onError(DatabaseError.noData)
                    return
                }
                do {
                    let object = try self.decodeObject(objectType, from: value, decoder: decoder)
                    observer.onNext(object)
                } catch {
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    func childAddedObservable<T: Decodable>(_ objectType: T.Type, from databaseReference: DatabaseReference, decoder: JSONDecoder?) -> Observable<T> {
        return Observable.create { observer in
            databaseReference.observe(.childAdded) { snapshot in
                guard let value = snapshot.value else {
                    observer.onError(DatabaseError.noData)
                    return
                }
                do {
                    let object = try self.decodeObject(objectType, from: value, decoder: decoder)
                    observer.onNext(object)
                } catch {
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    func childRemovedObservable<T: Decodable>(_ objectType: T.Type, from databaseReference: DatabaseReference, decoder: JSONDecoder?) -> Observable<T> {
        return Observable.create { observer in
            databaseReference.observe(.childRemoved) { snapshot in
                guard let value = snapshot.value else {
                    observer.onError(DatabaseError.noData)
                    return
                }
                do {
                    let object = try self.decodeObject(objectType, from: value, decoder: decoder)
                    observer.onNext(object)
                } catch {
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    private func decodeObject<T: Decodable>(_ objectType: T.Type, from json: Any, decoder: JSONDecoder?) throws -> T {
        let decoder = decoder ?? jsonDecoder
        let jsonData = try JSONSerialization.data(withJSONObject: json)
        return try decoder.decode(objectType, from: jsonData)
    }
}
