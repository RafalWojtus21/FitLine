//
//  ObservableTypeExtension.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 12/05/2023.
//

import Foundation
import RxSwift

extension ObservableType {

    public func pausable<Pauser: ObservableType> (_ pauser: Pauser) -> Observable<Element> where Pauser.Element == Bool {
        return withLatestFrom(pauser) { element, paused in
            (element, paused)
        }
        .filter { _, paused in paused }
        .map { element, _ in element }
    }
}
