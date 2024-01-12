//
//  EditPersonalDataScreenContract.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 12/01/2024.
//

import RxSwift

enum EditPersonalDataScreenIntent {
    case viewLoaded
    case cellSelected(_ userInfoType: UserInfoType)
    case edit(_ userInfoType: UserInfoType, newValue: String)
    case doneButtonIntent
}

struct EditPersonalDataScreenViewState: Equatable {
    var userInfo: UserInfo?
    var sexDataModel = SexDataModel.generateSexesList()
}

enum EditPersonalDataScreenEffect: Equatable {
    case edit(_ userInfoType: UserInfoType)
    case somethingWentWrong(error: String)
    case dismiss
    case idle
}

struct EditPersonalDataScreenBuilderInput {
}

protocol EditPersonalDataScreenCallback {
}

enum EditPersonalDataScreenResult: Equatable {
    case partialState(_ value: EditPersonalDataScreenPartialState)
    case effect(_ value: EditPersonalDataScreenEffect)
}

enum EditPersonalDataScreenPartialState: Equatable {
    case setUserInfo(userInfo: UserInfo)
    func reduce(previousState: EditPersonalDataScreenViewState) -> EditPersonalDataScreenViewState {
        var state = previousState
        switch self {
        case .setUserInfo(userInfo: let userInfo):
            state.userInfo = userInfo
        }
        return state
    }
}

protocol EditPersonalDataScreenBuilder {
    func build(with input: EditPersonalDataScreenBuilderInput) -> EditPersonalDataScreenModule
}

struct EditPersonalDataScreenModule {
    let view: EditPersonalDataScreenView
    let callback: EditPersonalDataScreenCallback
}

protocol EditPersonalDataScreenView: BaseView {
    var intents: Observable<EditPersonalDataScreenIntent> { get }
    func render(state: EditPersonalDataScreenViewState)
}

protocol EditPersonalDataScreenPresenter: AnyObject, BasePresenter {
    func bindIntents(view: EditPersonalDataScreenView, triggerEffect: PublishSubject<EditPersonalDataScreenEffect>) -> Observable<EditPersonalDataScreenViewState>
}

protocol EditPersonalDataScreenInteractor: BaseInteractor {
    func fetchUserInfo() -> Observable<EditPersonalDataScreenResult>
    func edit(_ userInfoType: UserInfoType, newValue: String) -> Observable<EditPersonalDataScreenResult>
    func saveUserInfo() -> Observable<EditPersonalDataScreenResult>
}

protocol EditPersonalDataScreenMiddleware {
    var middlewareObservable: Observable<EditPersonalDataScreenResult> { get }
    func process(result: EditPersonalDataScreenResult) -> Observable<EditPersonalDataScreenResult>
}
