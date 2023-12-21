//
//  UserInfo.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 11/04/2023.
//

import Foundation

struct UserInfo: Codable, Equatable {
    let firstName: String?
    let lastName: String?
    let sex: String?
    let age: Int?
    let height: Int?
    let weight: Int?
}
