//
//  RealtimeDatabaseServiceMock.swift
//  FitmaniaTests
//
//  Created by Rafał Wojtuś on 22/05/2023.
//

import Foundation
import RxSwift
import FirebaseDatabase
import FirebaseDatabaseSwift
import FirebaseCore

@testable import Fitmania

final class RealtimeDatabaseServiceMock: RealtimeDatabaseService {
    var saveResponse: CompletableEvent = .completed
    func save<T>(_ object: T, at path: String, encoder: JSONEncoder?) -> RxSwift.Completable where T : Encodable {
        saveResponse.asCompletable()
    }
    
    var fetchDataSingleResponse: Single<Decodable> = Single.never()
    func fetchDataSingle<T>(_ objectType: T.Type, from path: String, decoder: JSONDecoder?) -> RxSwift.Single<T> where T : Decodable {
        return fetchDataSingleResponse
            .flatMap { object -> Single<T> in
                if let typedObject = object as? T {
                    return .just(typedObject)
                } else {
                    return .error(DatabaseError.somethingWentWrong)
                }
            }
            .catch { error in
                Single.error(error)
            }
    }
    
    var fetchDataObservableResponse: Observable<Decodable> = Observable.never()
    func fetchDataObservable<T>(_ objectType: T.Type, from path: String, decoder: JSONDecoder?) -> RxSwift.Observable<T> where T : Decodable {
        return fetchDataObservableResponse
            .compactMap { $0 as? T }
            .catch { error in
                Observable.error(error)
            }
    }
    
    var deleteResponse: CompletableEvent = .completed
    func delete(from path: String) -> RxSwift.Completable {
        deleteResponse.asCompletable()
    }
    
    var childRemovedObservableResponse: Observable<Decodable> = Observable.never()
    func childRemovedObservable<T>(_ objectType: T.Type, from path: String, decoder: JSONDecoder?) -> RxSwift.Observable<T> where T : Decodable {
        return childRemovedObservableResponse
            .compactMap { $0 as? T }
            .catch { error in
                Observable.error(error)
            }
    }
    
    var childAddedObservableResponse: Observable<Decodable> = Observable.never()
    func childAddedObservable<T>(_ objectType: T.Type, from path: String, decoder: JSONDecoder?) -> RxSwift.Observable<T> where T : Decodable {
        return childAddedObservableResponse
            .compactMap { $0 as? T }
            .catch { error in
                Observable.error(error)
            }
    }
}
