//
//  LightenUpObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum LightenUpObjectType {
    case empty
    case lightbulb(state: AllowedObjectState)
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
    static func fromString(str: String) -> LightenUpObjectType {
        switch str {
        case "lightbulb":
            return .lightbulb(state: .normal)
        case "marker":
            return .marker
        default:
            return .empty
        }
    }
}

struct LightenUpObject {
    var objType = LightenUpObjectType()
    var lightness = 0
}

struct LightenUpGameMove {
    var p = Position()
    var objType = LightenUpObjectType()
}

