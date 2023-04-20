//
//  test.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 04/05/2023.
//

import RxSwift
import RxBlocking

extension Completable {
    func toArrayAndBlocking() throws -> Event<Never> {
        return try self
            .asObservable()
            .materialize()
            .toBlocking()
            .first()!
    }
}

extension Single {
    func toArrayAndBlocking() throws -> Array<Event<Element>> {
        return try self.asObservable()
            .materialize()
            .toArray()
            .toBlocking()
            .first()!
    }
}
