//
//  YoutubePreviewScreenInteractor.swift
//  FitLine
//
//  Created by Rafał Wojtuś on 26/01/2024.
//

import RxSwift

final class YoutubePreviewScreenInteractorImpl: YoutubePreviewScreenInteractor {
    
    // MARK: Properties
    
    typealias Dependencies = Any
    typealias Result = YoutubePreviewScreenResult
    
    private let dependencies: Dependencies
    
    // MARK: Initialization

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: Public Implementation
    
    // MARK: Private Implementation
}
