//
//  TierraDelFuegoObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum TierraDelFuegoObject {
    case empty
    case forbidden
    case marker
    case water(state: AllowedObjectState = .normal)
    case hint(id: Character, state: HintState)
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
    static func fromString(str: String) -> TierraDelFuegoObject {
        switch str {
        case "marker":
            return .marker
        case "water":
            return .water(state: .normal)
        default:
            return .empty
        }
    }
}

struct TierraDelFuegoGameMove {
    var p = Position()
    var obj = TierraDelFuegoObject()
}
