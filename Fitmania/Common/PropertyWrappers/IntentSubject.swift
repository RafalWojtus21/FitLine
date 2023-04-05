//
//  IntentSubject.swift
//  AcademyMVI
//
//  Created by Bart on 15/11/2021.
//

import Foundation
import RxSwift

@propertyWrapper
struct IntentSubject<T> {
    let subject: PublishSubject<T>
    
    init(subject: PublishSubject<T> = .init()) {
        self.subject = subject
    }
    
    var wrappedValue: Observable<T> { subject }
}
