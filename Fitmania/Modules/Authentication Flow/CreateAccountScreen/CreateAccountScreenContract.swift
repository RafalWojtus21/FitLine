//
//  CreateAccountScreenContract.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 10/04/2023.
//

import RxSwift

struct SexDataModel: Codable, Equatable {
    var sex: String
    
    static func generateSexesList() -> [SexDataModel] {
        [
            SexDataModel(sex: Localization.AuthenticationFlow.sexMale),
            SexDataModel(sex: Localization.AuthenticationFlow.sexFemale),
            SexDataModel(sex: Localization.AuthenticationFlow.sexOther)
        ]
    }
}

enum CreateAccountScreenIntent {
    case createAccountButtonIntent(userInfo: UserInfo)
    case validateName(text: String)
    case validateLastName(text: String)
    case validateSex(text: String)
    case validateAge(text: String)
    case validateHeight(text: String)
    case validateWeight(text: String)
    case invalidCredentials
}

struct CreateAccountScreenViewState: Equatable {
    typealias L = Localization.AuthenticationFlow
    
    var sexDataModel = SexDataModel.generateSexesList()
    var firstNameValidationMessage = ValidationMessage(message: "")
    var lastNameValidationMessage = ValidationMessage(message: "")
    var sexValidationMessage = ValidationMessage(message: "")
    var ageValidationMessage = ValidationMessage(message: "")
    var heightValidationMessage = ValidationMessage(message: "")
    var weightValidationMessage = ValidationMessage(message: "")
    var isCreateAccountButtonEnable: Bool { return firstNameValidationMessage.isValid && lastNameValidationMessage.isValid && sexValidationMessage.isValid && ageValidationMessage.isValid && heightValidationMessage.isValid && weightValidationMessage.isValid }
}

enum CreateAccountScreenEffect: Equatable {
    case showAccountCreatedScreen
    case somethingWentWrong(error: String)
    case invalidCredentials
}

struct CreateAccountScreenBuilderInput {
}

protocol CreateAccountScreenCallback {
}

enum CreateAccountScreenResult: Equatable {
    case partialState(_ value: CreateAccountScreenPartialState)
    case effect(_ value: CreateAccountScreenEffect)
}

enum CreateAccountScreenPartialState: Equatable {
    case firstNameValidationResult(validationMessage: ValidationMessage)
    case lastNameValidationResult(validationMessage: ValidationMessage)
    case sexValidationResult(validationMessage: ValidationMessage)
    case ageValidationResult(validationMessage: ValidationMessage)
    case heightValidationResult(validationMessage: ValidationMessage)
    case weightValidationResult(validationMessage: ValidationMessage)
    
    func reduce(previousState: CreateAccountScreenViewState) -> CreateAccountScreenViewState {
        var state = previousState
        switch self {
        case .firstNameValidationResult(validationMessage: let validationMessage):
            state.firstNameValidationMessage = validationMessage
        case .lastNameValidationResult(validationMessage: let validationMessage):
            state.lastNameValidationMessage = validationMessage
        case .sexValidationResult(validationMessage: let validationMessage):
            state.sexValidationMessage = validationMessage
        case .ageValidationResult(validationMessage: let validationMessage):
            state.ageValidationMessage = validationMessage
        case .heightValidationResult(validationMessage: let validationMessage):
            state.heightValidationMessage = validationMessage
        case .weightValidationResult(validationMessage: let validationMessage):
            state.weightValidationMessage = validationMessage
        }
        return state
    }
}

protocol CreateAccountScreenBuilder {
    func build(with input: CreateAccountScreenBuilderInput) -> CreateAccountScreenModule
}

struct CreateAccountScreenModule {
    let view: CreateAccountScreenView
    let callback: CreateAccountScreenCallback
}

protocol CreateAccountScreenView: BaseView {
    var intents: Observable<CreateAccountScreenIntent> { get }
    func render(state: CreateAccountScreenViewState)
}

protocol CreateAccountScreenPresenter: AnyObject, BasePresenter {
    func bindIntents(view: CreateAccountScreenView, triggerEffect: PublishSubject<CreateAccountScreenEffect>) -> Observable<CreateAccountScreenViewState>
}

protocol CreateAccountScreenInteractor: BaseInteractor {
    func saveUserInfo(userInfo: UserInfo) -> Observable<CreateAccountScreenResult>
    func validateName(name: String) -> Observable<CreateAccountScreenResult>
    func validateLastName(lastName: String) -> Observable<CreateAccountScreenResult>
    func validateSex(sex: String) -> Observable<CreateAccountScreenResult>
    func validateAge(age: String) -> Observable<CreateAccountScreenResult>
    func validateHeight(height: String) -> Observable<CreateAccountScreenResult>
    func validateWeight(weight: String) -> Observable<CreateAccountScreenResult>
}

protocol CreateAccountScreenMiddleware {
    var middlewareObservable: Observable<CreateAccountScreenResult> { get }
    func process(result: CreateAccountScreenResult) -> Observable<CreateAccountScreenResult>
}
