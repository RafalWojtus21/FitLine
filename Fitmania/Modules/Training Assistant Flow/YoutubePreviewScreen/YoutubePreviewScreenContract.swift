//
//  YoutubePreviewScreenContract.swift
//  FitLine
//
//  Created by Rafał Wojtuś on 26/01/2024.
//

import RxSwift

enum YoutubePreviewScreenIntent {
}

struct YoutubePreviewScreenViewState: Equatable {
    let videoID: String?
}

enum YoutubePreviewScreenEffect: Equatable {
}

struct YoutubePreviewScreenBuilderInput {
    let videoID: String?
}

protocol YoutubePreviewScreenCallback {
}

enum YoutubePreviewScreenResult: Equatable {
    case partialState(_ value: YoutubePreviewScreenPartialState)
    case effect(_ value: YoutubePreviewScreenEffect)
}

enum YoutubePreviewScreenPartialState: Equatable {
    func reduce(previousState: YoutubePreviewScreenViewState) -> YoutubePreviewScreenViewState {
        let state = previousState
        switch self {
        }
        return state
    }
}

protocol YoutubePreviewScreenBuilder {
    func build(with input: YoutubePreviewScreenBuilderInput) -> YoutubePreviewScreenModule
}

struct YoutubePreviewScreenModule {
    let view: YoutubePreviewScreenView
    let callback: YoutubePreviewScreenCallback
}

protocol YoutubePreviewScreenView: BaseView {
    var intents: Observable<YoutubePreviewScreenIntent> { get }
    func render(state: YoutubePreviewScreenViewState)
}

protocol YoutubePreviewScreenPresenter: AnyObject, BasePresenter {
    func bindIntents(view: YoutubePreviewScreenView, triggerEffect: PublishSubject<YoutubePreviewScreenEffect>) -> Observable<YoutubePreviewScreenViewState>
}

protocol YoutubePreviewScreenInteractor: BaseInteractor {
}

protocol YoutubePreviewScreenMiddleware {
    var middlewareObservable: Observable<YoutubePreviewScreenResult> { get }
    func process(result: YoutubePreviewScreenResult) -> Observable<YoutubePreviewScreenResult>
}
