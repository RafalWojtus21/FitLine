//
//  ValidationServiceMock.swift
//  FitmaniaTests
//
//  Created by Rafał Wojtuś on 20/04/2023.
//

import Foundation
import RxSwift
@testable import Fitmania

final class ValidationServiceMock: ValidationService {
    var validateResponse: CompletableEvent = .completed
    func validate(_ type: Validation.ValidationType, input: String) -> Completable {
        validateResponse.asCompletable()
    }
}
