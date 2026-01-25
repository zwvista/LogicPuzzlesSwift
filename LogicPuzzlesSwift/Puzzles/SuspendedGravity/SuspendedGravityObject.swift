//
//  SuspendedGravityObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum SuspendedGravityObject {
    case empty
    case marker
    case forbidden
    case block(state: AllowedObjectState = .normal)
    init() {
        self = .empty
    }
    func toString() -> String {
        switch self {
        case .block:
            return "block"
        case .marker:
            return "marker"
        case .forbidden:
            return "forbidden"
        default:
            return "empty"
        }
    }
    static func fromString(str: String) -> SuspendedGravityObject {
        switch str {
        case "block":
            return .block()
        case "marker":
            return .marker
        default:
            return .empty
        }
    }
}

struct SuspendedGravityGameMove {
    var p = Position()
    var obj = SuspendedGravityObject()
}
