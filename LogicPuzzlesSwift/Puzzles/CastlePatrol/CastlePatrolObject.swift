//
//  CastlePatrolObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum CastlePatrolObjectType {
    case empty
    case lightbulb(state: AllowedObjectState = .normal)
    case marker
    case wall(state: HintState)
    init() {
        self = .empty
    }
    func toString() -> String {
        switch self {
        case .lightbulb:
            return "lightbulb"
        case .marker:
            return "marker"
        default:
            return "empty"
        }
    }
    static func fromString(str: String) -> CastlePatrolObjectType {
        switch str {
        case "lightbulb":
            return .lightbulb()
        case "marker":
            return .marker
        default:
            return .empty
        }
    }
}

struct CastlePatrolObject {
    var objType = CastlePatrolObjectType()
    var lightness = 0
}

struct CastlePatrolGameMove {
    var p = Position()
    var objType = CastlePatrolObjectType()
}

