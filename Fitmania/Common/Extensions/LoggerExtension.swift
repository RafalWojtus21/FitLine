//
//  LoggerExtension.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 09/05/2023.
//

import Foundation
import OSLog
typealias Log = Logger

extension Logger {
    // swiftlint:disable:next force_unwrapping
    private static let subsystem = Bundle.main.bundleIdentifier!
    
    static let workoutCreator = Logger(subsystem: subsystem, category: "workoutCreator")   
}
