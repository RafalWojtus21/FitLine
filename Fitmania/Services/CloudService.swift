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
    
    var path: String {
        switch self {
        case .userInfo:
            return "usersInfo"
        case .workouts:
            return "workouts"
        case .workoutsPublic:
            return "workouts/public"
        }
    }
}

protocol HasCloudService {
    var cloudService: CloudService { get }
}

protocol CloudService {
    func savePublicData<T: Encodable>(data: T, endpoint: DatabaseEndpoints, encoder: JSONEncoder?) -> Completable
    func savePersonalData<T: Encodable>(data: T, endpoint: DatabaseEndpoints, encoder: JSONEncoder?) -> Completable
    func fetchPublicDataSingle<T: Decodable>(type: T.Type, endpoint: DatabaseEndpoints, decoder: JSONDecoder?) -> Single<T>
    func fetchPersonalDataSingle<T: Decodable>(type: T.Type, endpoint: DatabaseEndpoints, decoder: JSONDecoder?) -> Single<T>
    func fetchPersonalDataObservable<T: Decodable>(type: T.Type, endpoint: DatabaseEndpoints, decoder: JSONDecoder?) -> Observable<T>
}

final class CloudServiceImpl: CloudService {
    
    // MARK: Properties
    
    enum FirestoreCollectionPaths: String {
        case usersInfo
    }
    
    private let bag = DisposeBag()
    private let authManager: AuthManager
    private let realtimeService: RealtimeDatabaseService
    private let database: Database
    
    // MARK: Initialization

    init(authManager: AuthManager, realtimeService: RealtimeDatabaseService) {
        self.authManager = authManager
        self.realtimeService = realtimeService
        self.database = realtimeService.database
    }
    
    // MARK: Public Implementation
    
    func savePublicData<T: Encodable>(data: T, endpoint: DatabaseEndpoints, encoder: JSONEncoder?) -> Completable {
        let reference = realtimeService.database.reference(withPath: endpoint.path)
        return realtimeService.save(data, at: reference, encoder: encoder)
    }
    
    func savePersonalData<T: Encodable>(data: T, endpoint: DatabaseEndpoints, encoder: JSONEncoder?) -> Completable {
        let reference: DatabaseReference
        do {
            reference = realtimeService.database.reference(withPath: try getDestination(from: endpoint))
        } catch {
            return Completable.error(error)
        }
        return realtimeService.save(data, at: reference, encoder: encoder)
    }
    
    func fetchPublicDataSingle<T: Decodable>(type: T.Type, endpoint: DatabaseEndpoints, decoder: JSONDecoder?) -> Single<T> {
        let reference = realtimeService.database.reference(withPath: endpoint.path)
        return realtimeService.fetchDataSingle(type, from: reference, decoder: decoder)
    }
    
    func fetchPersonalDataSingle<T: Decodable>(type: T.Type, endpoint: DatabaseEndpoints, decoder: JSONDecoder?) -> Single<T> {
        let reference: DatabaseReference
        do {
            reference = realtimeService.database.reference(withPath: try getDestination(from: endpoint))
        } catch {
            return Single.error(error)
        }
        return realtimeService.fetchDataSingle(type, from: reference, decoder: decoder)
    }
    
    func fetchPersonalDataObservable<T: Decodable>(type: T.Type, endpoint: DatabaseEndpoints, decoder: JSONDecoder?) -> Observable<T> {
        let reference: DatabaseReference
        do {
            reference = realtimeService.database.reference(withPath: try getDestination(from: endpoint))
        } catch {
            return Observable.error(error)
        }
        return realtimeService.fetchDataObservable(type, from: reference, decoder: decoder)
    }
    
    private func getDestination(from endpoint: DatabaseEndpoints) throws -> String {
        guard let userID = authManager.getCurrentUser()?.uid else {
            throw AuthError.unauthenticatedUser
        }
        return endpoint.path.withTrailingSlash + userID
    }
}

extension CloudService {
    func savePublicData<T: Encodable>(data: T, endpoint: DatabaseEndpoints) -> Completable {
        return savePublicData(data: data, endpoint: endpoint, encoder: nil)
    }
    
    func savePersonalData<T: Encodable>(data: T, endpoint: DatabaseEndpoints) -> Completable {
        return savePersonalData(data: data, endpoint: endpoint, encoder: nil)
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
}
