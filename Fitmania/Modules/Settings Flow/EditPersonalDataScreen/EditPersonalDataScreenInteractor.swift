//
//  EditPersonalDataScreenInteractor.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 12/01/2024.
//

import RxSwift

final class EditPersonalDataScreenInteractorImpl: EditPersonalDataScreenInteractor {
    
    // MARK: Properties
    
    typealias Dependencies = HasCloudService
    typealias Result = EditPersonalDataScreenResult
    
    private let dependencies: Dependencies
    private var userInfo: UserInfo?
    
    // MARK: Initialization

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: Public Implementation
    
    func fetchUserInfo() -> Observable<EditPersonalDataScreenResult> {
        dependencies.cloudService.fetchPersonalDataSingle(type: UserInfo.self, endpoint: .userInfo)
            .map { userInfo in
                self.userInfo = userInfo
                return .partialState(.setUserInfo(userInfo: userInfo))
            }
            .asObservable()
    }
    
    func edit(_ userInfoType: UserInfoType, newValue: String) -> Observable<EditPersonalDataScreenResult> {
        switch userInfoType {
        case .firstName:
            userInfo?.firstName = .firstName(newValue)
        case .lastName:
            userInfo?.lastName = .lastName(newValue)
        case .sex:
            userInfo?.sex = .sex(.init(sex: newValue))
        case .age:
            if let age = Int(newValue) {
                userInfo?.age = .age(age)
            }
        case .height:
            if let height = Int(newValue) {
                userInfo?.height = .height(height)
            }
        case .weight:
            if let weight = Int(newValue) {
                userInfo?.weight = .weight(weight)
            }
        }
        guard let userInfo else { return .just(.effect(.idle)) }
        return .just(.partialState(.setUserInfo(userInfo: userInfo)))
    }
    
    func saveUserInfo() -> Observable<EditPersonalDataScreenResult> {
        guard let userInfo else { return .just(.effect(.idle))}
        return dependencies.cloudService.savePersonalData(data: userInfo, endpoint: .userInfo, encoder: nil)
            .andThen(.just(.effect(.dismiss)))
            .catch { error -> Observable<EditPersonalDataScreenResult> in
                return .just(.effect(.somethingWentWrong(error: error.localizedDescription)))
            }
    }
    
    // MARK: Private Implementation
    
}
