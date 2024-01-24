//
//  CloudService.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 12/04/2023.
//

import Foundation
import RxSwift
import FirebaseDatabase
import FirebaseDatabaseSwift

enum DatabaseEndpoints {
    case userInfo
    case workouts
    case workoutsPublic
    case workoutsHistory
    
    var path: String {
        switch self {
        case .userInfo:
            return "usersInfo"
        case .workouts:
            return "workouts"
        case .workoutsPublic:
            return "workouts/public"
        case .workoutsHistory:
            return "workoutsHistory"
        }
    }
}

protocol HasCloudService {
    var cloudService: CloudService { get }
}

protocol CloudService {
    func savePersonalDataWithID<T: Encodable>(data: T, endpoint: DatabaseEndpoints, encoder: JSONEncoder?, dataID: UUID?) -> Completable
    func deletePersonalDataWithID(endpoint: DatabaseEndpoints, dataID: UUID?) -> Completable
    func savePublicData<T: Encodable>(data: T, endpoint: DatabaseEndpoints, encoder: JSONEncoder?) -> Completable
    func savePersonalData<T: Encodable>(data: T, endpoint: DatabaseEndpoints, encoder: JSONEncoder?) -> Completable
    func fetchPublicDataSingle<T: Decodable>(type: T.Type, endpoint: DatabaseEndpoints, decoder: JSONDecoder?) -> Single<T>
    func fetchPersonalDataSingle<T: Decodable>(type: T.Type, endpoint: DatabaseEndpoints, decoder: JSONDecoder?) -> Single<T>
    func fetchPersonalDataObservable<T: Decodable>(type: T.Type, endpoint: DatabaseEndpoints, decoder: JSONDecoder?) -> Observable<T>
    func childAddedObservable<T: Decodable>(type: T.Type, endpoint: DatabaseEndpoints, decoder: JSONDecoder?) -> Observable<T>
    func childRemovedObservable<T: Decodable>(type: T.Type, endpoint: DatabaseEndpoints, decoder: JSONDecoder?) -> Observable<T>
    func childChangedObservable<T: Decodable>(type: T.Type, endpoint: DatabaseEndpoints, decoder: JSONDecoder?) -> Observable<T>
}

final class CloudServiceImpl: CloudService {
    
    // MARK: Properties
    
    private let bag = DisposeBag()
    private let authManager: AuthManager
    private let realtimeService: RealtimeDatabaseService
    
    // MARK: Initialization
    
    init(authManager: AuthManager, realtimeService: RealtimeDatabaseService) {
        self.authManager = authManager
        self.realtimeService = realtimeService
    }
    
    // MARK: Public Implementation
    
    func savePublicData<T: Encodable>(data: T, endpoint: DatabaseEndpoints, encoder: JSONEncoder?) -> Completable {
        return realtimeService.save(data, at: endpoint.path, encoder: encoder)
    }
    
    func savePersonalData<T: Encodable>(data: T, endpoint: DatabaseEndpoints, encoder: JSONEncoder?) -> Completable {
        do {
            let reference = try getPrivateDestination(from: endpoint, dataID: nil)
            return realtimeService.save(data, at: reference, encoder: encoder)
        } catch {
            return Completable.error(error)
        }
    }
    
    func savePersonalDataWithID<T: Encodable>(data: T, endpoint: DatabaseEndpoints, encoder: JSONEncoder?, dataID: UUID?) -> Completable {
        do {
            let reference = try getPrivateDestination(from: endpoint, dataID: dataID)
            return realtimeService.save(data, at: reference, encoder: encoder)
        } catch {
            return Completable.error(error)
        }
    }
    
    func fetchPublicDataSingle<T: Decodable>(type: T.Type, endpoint: DatabaseEndpoints, decoder: JSONDecoder?) -> Single<T> {
        let reference = endpoint.path
        return realtimeService.fetchDataSingle(type, from: reference, decoder: decoder)
    }
    
    func fetchPersonalDataSingle<T: Decodable>(type: T.Type, endpoint: DatabaseEndpoints, decoder: JSONDecoder?) -> Single<T> {
        do {
            let reference = try getPrivateDestination(from: endpoint, dataID: nil)
            return realtimeService.fetchDataSingle(type, from: reference, decoder: decoder)
        } catch {
            return Single.error(error)
        }
    }
    
    func fetchPersonalDataObservable<T: Decodable>(type: T.Type, endpoint: DatabaseEndpoints, decoder: JSONDecoder?) -> Observable<T> {
        do {
            let reference = try getPrivateDestination(from: endpoint, dataID: nil)
            return realtimeService.fetchDataObservable(type, from: reference, decoder: decoder)
        } catch {
            return Observable.error(error)
        }
    }
    
    func deletePersonalDataWithID(endpoint: DatabaseEndpoints, dataID: UUID?) -> Completable {
        do {
            let reference = try getPrivateDestination(from: endpoint, dataID: dataID)
            return realtimeService.delete(from: reference)
        } catch {
            return Completable.error(error)
        }
    }
    
    func childAddedObservable<T: Decodable>(type: T.Type, endpoint: DatabaseEndpoints, decoder: JSONDecoder?) -> Observable<T> {
        do {
            let reference = try getPrivateDestination(from: endpoint, dataID: nil)
            return realtimeService.childAddedObservable(type, from: reference, decoder: decoder)
        } catch {
            return Observable.error(error)
        }
    }
    
    func childRemovedObservable<T: Decodable>(type: T.Type, endpoint: DatabaseEndpoints, decoder: JSONDecoder?) -> Observable<T> {
        do {
            let reference = try getPrivateDestination(from: endpoint, dataID: nil)
            return realtimeService.childRemovedObservable(type, from: reference, decoder: decoder)
        } catch {
            return Observable.error(error)
        }
    }
    
    func childChangedObservable<T: Decodable>(type: T.Type, endpoint: DatabaseEndpoints, decoder: JSONDecoder?) -> Observable<T> {
        do {
            let reference = try getPrivateDestination(from: endpoint, dataID: nil)
            return realtimeService.childChangedObservable(type, from: reference, decoder: decoder)
        } catch {
            return Observable.error(error)
        }
    }
    
    private func getPrivateDestination(from endpoint: DatabaseEndpoints, dataID: UUID?) throws -> String {
        guard let userID = authManager.getCurrentUser()?.uid else {
            throw AuthError.unauthenticatedUser
        }
        let destinationPath = endpoint.path.withTrailingSlash + userID
        guard let dataID else { return destinationPath }
        let reference = destinationPath.withTrailingSlash + dataID.uuidString
        return reference
    }
}

extension CloudService {
    func savePublicData<T: Encodable>(data: T, endpoint: DatabaseEndpoints) -> Completable {
        return savePublicData(data: data, endpoint: endpoint, encoder: nil)
    }
    
    func savePersonalData<T: Encodable>(data: T, endpoint: DatabaseEndpoints) -> Completable {
        return savePersonalData(data: data, endpoint: endpoint, encoder: nil)
    }
    
    func savePersonalDataWithID<T: Encodable>(data: T, endpoint: DatabaseEndpoints, id: UUID?) -> Completable {
        return savePersonalDataWithID(data: data, endpoint: endpoint, encoder: nil, dataID: id)
    }
    
    func fetchPublicDataSingle<T: Decodable>(type: T.Type, endpoint: DatabaseEndpoints) -> Single<T> {
        return fetchPublicDataSingle(type: type, endpoint: endpoint, decoder: nil)
    }
    
    func fetchPersonalDataSingle<T: Decodable>(type: T.Type, endpoint: DatabaseEndpoints) -> Single<T> {
        return fetchPersonalDataSingle(type: type, endpoint: endpoint, decoder: nil)
    }
    
    func fetchPersonalDataObservable<T: Decodable>(type: T.Type, endpoint: DatabaseEndpoints) -> Observable<T> {
        return fetchPersonalDataObservable(type: type, endpoint: endpoint, decoder: nil)
    }
    
    func childRemovedObservable<T: Decodable>(type: T.Type, endpoint: DatabaseEndpoints) -> Observable<T> {
        return childRemovedObservable(type: type, endpoint: endpoint, decoder: nil)
    }
    
    func childAddedObservable<T: Decodable>(type: T.Type, endpoint: DatabaseEndpoints) -> Observable<T> {
        return childAddedObservable(type: type, endpoint: endpoint, decoder: nil)
    }
}
