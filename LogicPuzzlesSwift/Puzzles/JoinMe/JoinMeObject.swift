//
//  JoinMeObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum JoinMeObject {
    case empty
    case forbidden
    case marker
    case water(state: AllowedObjectState = .normal)
    init() {
        self = .empty
    }
    func toString() -> String {
        switch self {
        case .marker:
            return "marker"
        case .water:
            return "water"
        default:
            return "empty"
        }
    }
    static func fromString(str: String) -> JoinMeObject {
        switch str {
        case "marker":
            return .marker
        case "water":
            return .water()
        default:
            return .empty
        }
    }
}

struct JoinMeGameMove {
    var p = Position()
    var obj = JoinMeObject()
}
