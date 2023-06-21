//
//  CloudServiceMock.swift
//  FitmaniaTests
//
//  Created by Rafał Wojtuś on 24/04/2023.
//

import Foundation
import RxSwift
@testable import Fitmania

final class CloudServiceMock: CloudService {
    
    var savePublicDataResponse: CompletableEvent = .completed
    func savePublicData<T>(data: T, endpoint: Fitmania.DatabaseEndpoints, encoder: JSONEncoder?) -> RxSwift.Completable where T : Encodable {
        savePublicDataResponse.asCompletable()
    }
    
    var savePersonalDataResponse: CompletableEvent = .completed
    func savePersonalData<T>(data: T, endpoint: Fitmania.DatabaseEndpoints, encoder: JSONEncoder?) -> RxSwift.Completable where T : Encodable {
        savePersonalDataResponse.asCompletable()
    }
    
    var savePersonalDataWithIDResponse: CompletableEvent = .completed
    func savePersonalDataWithID<T>(data: T, endpoint: Fitmania.DatabaseEndpoints, encoder: JSONEncoder?, dataID: UUID?) -> RxSwift.Completable where T : Encodable {
        savePersonalDataWithIDResponse.asCompletable()
    }
    
    var fetchPublicDataSingleResponse: Single<Decodable> = Single.never()
    func fetchPublicDataSingle<T>(type: T.Type, endpoint: Fitmania.DatabaseEndpoints, decoder: JSONDecoder?) -> RxSwift.Single<T> where T : Decodable {
        return fetchPublicDataSingleResponse
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
    
    var fetchPersonalDataSingleResponse: Single<Decodable> = Single.never()
    func fetchPersonalDataSingle<T>(type: T.Type, endpoint: Fitmania.DatabaseEndpoints, decoder: JSONDecoder?) -> RxSwift.Single<T> where T : Decodable {
        return fetchPersonalDataSingleResponse
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
    
    var fetchPersonalDataObservableResponse: Observable<Decodable> = Observable.never()
    func fetchPersonalDataObservable<T>(type: T.Type, endpoint: Fitmania.DatabaseEndpoints, decoder: JSONDecoder?) -> RxSwift.Observable<T> where T : Decodable {
        return fetchPersonalDataObservableResponse
            .compactMap { $0 as? T }
            .catch { error in
                Observable.error(error)
            }
    }
    
    var deletePersonalDataWithIDResponse: CompletableEvent = .completed
    func deletePersonalDataWithID(endpoint: Fitmania.DatabaseEndpoints, dataID: UUID?) -> RxSwift.Completable {
        deletePersonalDataWithIDResponse.asCompletable()
    }
    
    var childAddedObservableResponse: Observable<Decodable> = Observable.never()
    func childAddedObservable<T>(type: T.Type, endpoint: Fitmania.DatabaseEndpoints, decoder: JSONDecoder?) -> RxSwift.Observable<T> where T : Decodable {
        return childAddedObservableResponse
            .compactMap { $0 as? T }
            .catch { error in
                Observable.error(error)
            }
    }

    var childRemovedObservableResponse: Observable<Decodable> = Observable.never()
    func childRemovedObservable<T>(type: T.Type, endpoint: Fitmania.DatabaseEndpoints, decoder: JSONDecoder?) -> RxSwift.Observable<T> where T : Decodable {
        return childRemovedObservableResponse
            .asObservable()
            .compactMap { $0 as? T }
            .catch { error in
                Observable.error(error)
            }
    }
}
