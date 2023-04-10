//
//  CloudService.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 12/04/2023.
//

import Foundation
import RxSwift

protocol HasCloudService {
    var cloudService: CloudService { get }
}

protocol CloudService {
    func saveNewData<T: Encodable>(data: T, collectionPath: CloudServiceImpl.FirestoreCollectionPaths) -> Completable
    func fetchData<T: Decodable>(type: T.Type, collectionPath: CloudServiceImpl.FirestoreCollectionPaths) -> Single<T> 
}

final class CloudServiceImpl: CloudService {
    enum FirestoreCollectionPaths: String {
        case usersInfo
    }
    
    private let bag = DisposeBag()
    private let authManager: AuthManager
    private let firestoreService: FirestoreService
    
    init(authManager: AuthManager, firestoreService: FirestoreService) {
        self.authManager = authManager
        self.firestoreService = firestoreService
    }
    
    func saveNewData<T: Encodable>(data: T, collectionPath: FirestoreCollectionPaths) -> Completable {
        guard let documentID = authManager.getCurrentUser()?.uid else { return .error(AuthError.userNotLoggedIn) }
        return firestoreService.saveData(data: data, collectionPath: collectionPath.rawValue, documentID: documentID)
    }
    
    func fetchData<T: Decodable>(type: T.Type, collectionPath: FirestoreCollectionPaths) -> Single<T> {
        guard let documentID = authManager.getCurrentUser()?.uid else { return .error(AuthError.userNotLoggedIn) }
        return firestoreService.fetchData(type: type, collectionPath: collectionPath.rawValue, documentID: documentID)
    }
}
