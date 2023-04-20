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
    var saveDataResponse: CompletableEvent = .completed
    func saveNewData<T>(data: T, collectionPath: Fitmania.CloudServiceImpl.FirestoreCollectionPaths) -> RxSwift.Completable where T : Encodable {
        saveDataResponse.asCompletable()
    }

    var fetchDataResponse: Decodable? = UserInfo(firstName: "name", lastName: "test", sex: "male", age: 121, height: nil, weight: nil)
    func fetchData<T>(type: T.Type, collectionPath: Fitmania.CloudServiceImpl.FirestoreCollectionPaths) -> RxSwift.Single<T> where T : Decodable {
        .just(fetchDataResponse as! T)
    }
}
