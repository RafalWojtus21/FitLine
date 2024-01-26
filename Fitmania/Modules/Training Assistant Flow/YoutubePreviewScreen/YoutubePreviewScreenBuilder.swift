//
//  YoutubePreviewScreenBuilder.swift
//  FitLine
//
//  Created by Rafał Wojtuś on 26/01/2024.
//

import UIKit
import RxSwift

final class YoutubePreviewScreenBuilderImpl: YoutubePreviewScreenBuilder {
    typealias Dependencies = YoutubePreviewScreenInteractorImpl.Dependencies & YoutubePreviewScreenMiddlewareImpl.Dependencies
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
        
    func build(with input: YoutubePreviewScreenBuilderInput) -> YoutubePreviewScreenModule {
        let interactor = YoutubePreviewScreenInteractorImpl(dependencies: dependencies)
        let middleware = YoutubePreviewScreenMiddlewareImpl(dependencies: dependencies)
        let presenter = YoutubePreviewScreenPresenterImpl(interactor: interactor, middleware: middleware, initialViewState: YoutubePreviewScreenViewState(videoID: input.videoID))
        let view = YoutubePreviewScreenViewController(presenter: presenter)
        return YoutubePreviewScreenModule(view: view, callback: middleware)
    }
}
