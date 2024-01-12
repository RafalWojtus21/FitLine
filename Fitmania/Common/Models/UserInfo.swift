//
//  UserInfo.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 11/04/2023.
//

import Foundation

struct UserInfo: Codable, Equatable, Sequence {
    var firstName: UserInfoType?
    var lastName: UserInfoType?
    var sex: UserInfoType?
    var age: UserInfoType?
    var height: UserInfoType?
    var weight: UserInfoType?
    
    struct Iterator: IteratorProtocol {
            private let userInfo: UserInfo
            private var currentIndex = 0

            init(userInfo: UserInfo) {
                self.userInfo = userInfo
            }

            mutating func next() -> UserInfoType? {
                switch currentIndex {
                case 0:
                    defer { currentIndex += 1 }
                    return userInfo.firstName
                case 1:
                    defer { currentIndex += 1 }
                    return userInfo.lastName
                case 2:
                    defer { currentIndex += 1 }
                    return userInfo.sex
                case 3:
                    defer { currentIndex += 1 }
                    return userInfo.age
                case 4:
                    defer { currentIndex += 1 }
                    return userInfo.height
                case 5:
                    defer { currentIndex += 1 }
                    return userInfo.weight
                default:
                    return nil
                }
            }
        }

        func makeIterator() -> Iterator {
            return Iterator(userInfo: self)
        }
}

enum UserInfoType: Codable, Equatable {
    case firstName(String)
    case lastName(String)
    case sex(SexDataModel)
    case age(Int)
    case height(Int)
    case weight(Int)
    
    var description: String {
        switch self {
        case .firstName:
            "First name"
        case .lastName:
            "Last name"
        case .sex:
            "Sex"
        case .age:
            "Age"
        case .height:
            "Height"
        case .weight:
            "Weight"
        }
    }
}
