//
//  TurnTwiceObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum TurnTwiceObject {
    case empty
    case forbidden
    case marker
    case signpost(state: AllowedObjectState)
    case wall
    init() {
        self = .empty
    }
    func toString() -> String {
        switch self {
        case .marker:
            return "marker"
        case .signpost:
            return "signpost"
        case .wall:
            return "wall"
        default:
            return "empty"
        }
    }
    static func fromString(str: String) -> TurnTwiceObject {
        switch str {
        case "marker":
            return .marker
        case "signpost":
            return .signpost(state: .normal)
        case "wall":
            return .wall
        default:
            return .empty
        }
    }
}

struct TurnTwiceGameMove {
    var p = Position()
    var obj = TurnTwiceObject()
}
