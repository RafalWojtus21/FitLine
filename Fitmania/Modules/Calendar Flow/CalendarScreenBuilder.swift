//
//  CalendarScreenBuilder.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 06/06/2023.
//

import UIKit
import RxSwift

final class CalendarScreenBuilderImpl: CalendarScreenBuilder {
    typealias Dependencies = CalendarScreenInteractorImpl.Dependencies & CalendarScreenMiddlewareImpl.Dependencies
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
        
    func build(with input: CalendarScreenBuilderInput) -> CalendarScreenModule {
        let interactor = CalendarScreenInteractorImpl(dependencies: dependencies)
        let middleware = CalendarScreenMiddlewareImpl(dependencies: dependencies)
        let presenter = CalendarScreenPresenterImpl(interactor: interactor, middleware: middleware, initialViewState: CalendarScreenViewState())
        let view = CalendarScreenViewController(presenter: presenter)
        return CalendarScreenModule(view: view, callback: middleware)
    }
}
