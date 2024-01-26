//
//  YoutubePreviewScreenMiddleware.swift
//  FitLine
//
//  Created by Rafał Wojtuś on 26/01/2024.
//

import RxSwift

final class YoutubePreviewScreenMiddlewareImpl: YoutubePreviewScreenMiddleware, YoutubePreviewScreenCallback {
    typealias Dependencies = HasAppNavigation
    typealias Result = YoutubePreviewScreenResult
    
    private let dependencies: Dependencies

    private let middlewareSubject = PublishSubject<Result>()
    var middlewareObservable: Observable<Result> { return middlewareSubject }
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    func process(result: Result) -> Observable<Result> {
        switch result {
        case .partialState(_): break
        case .effect(let effect):
            switch effect {
            }
        }
        return .just(result)
    }
}
