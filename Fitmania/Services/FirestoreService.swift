//
//  FirestoreService.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 11/04/2023.
//

import Foundation
import RxSwift
import Firebase
import FirebaseFirestoreSwift

protocol HasFirestoreService {
    var firestoreService: FirestoreService { get }
}

protocol FirestoreService {
    func saveData<T: Encodable>(data: T, collectionPath: String, documentID: String) -> Completable
    func fetchData<T: Decodable>(type: T.Type, collectionPath: String, documentID: String) -> Single<T>
}

final class FirestoreServiceImpl: FirestoreService {
    private let bag = DisposeBag()
    private let authManager: AuthManager
    
    init(authManager: AuthManager) {
        self.authManager = authManager
        getCurrentUser()
    }
    
    private let firestore = Firestore.firestore()
    private var currentUser: User?
    
    private func getCurrentUser() {
        self.currentUser = authManager.getCurrentUser()
    }
    
    func saveData<T: Encodable>(data: T, collectionPath: String, documentID: String) -> Completable {
        let documentReference = firestore.collection(collectionPath).document(documentID)
        return Completable.create { completable in
            do {
                let data = try Firestore.Encoder().encode(data)
                documentReference.setData(data) { error in
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
        .debug("Save data")
    }
    
    func fetchData<T: Decodable>(type: T.Type, collectionPath: String, documentID: String) -> Single<T> {
        let documentReference = firestore.collection(collectionPath).document(documentID)
        return Single.create { single in
            documentReference.getDocument { snapshot, error in
                if let error = error {
                    single(.failure(error))
                } else {
                    do {
                        guard let data = snapshot?.data() else {
                            throw FirestoreError.noData
                        }
                        let result = try Firestore.Decoder().decode(type, from: data)
                        single(.success(result))
                    } catch {
                        single(.failure(error))
                    }
                }
            }
            return Disposables.create()
        }
        .debug("Fetch data")
    }
}
