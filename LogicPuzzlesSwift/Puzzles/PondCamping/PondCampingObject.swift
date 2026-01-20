//
//  PondCampingObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum PondCampingObject {
    case empty
    case forbidden
    case marker
    case water
    case hint(tiles: Int, state: HintState)
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
    static func fromString(str: String) -> PondCampingObject {
        switch str {
        case "marker":
            return .marker
        case "water":
            return .water
        default:
            return .empty
        }
    }
}

struct PondCampingGameMove {
    var p = Position()
    var obj = PondCampingObject()
}
