//
//  CompletableEventExtension.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 24/04/2023.
//

import RxSwift

extension CompletableEvent {
    func asCompletable() -> Completable {
        Completable.create { observer in
            observer(self)
            return Disposables.create()
        }
    }
}
