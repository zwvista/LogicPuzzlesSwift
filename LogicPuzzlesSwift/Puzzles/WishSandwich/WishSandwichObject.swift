//
//  WishSandwichObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum WishSandwichObject {
    case empty
    case forbidden
    case marker
    case post(state: AllowedObjectState)
    init() {
        self = .empty
    }
    func toString() -> String {
        switch self {
        case .marker:
            return "marker"
        case .post:
            return "post"
        default:
            return "empty"
        }
    }
    static func fromString(str: String) -> WishSandwichObject {
        switch str {
        case "marker":
            return .marker
        case "post":
            return .post(state: .normal)
        default:
            return .empty
        }
    }
}

struct WishSandwichGameMove {
    var p = Position()
    var obj = WishSandwichObject()
}

