//
//  ParkLakesObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum ParkLakesObject {
    case empty
    case marker
    case lake(state: AllowedObjectState = .normal)
    case hint(tiles: Int, state: HintState)
    init() {
        self = .empty
    }
    func toString() -> String {
        switch self {
        case .marker:
            return "marker"
        case .lake:
            return "lake"
        default:
            return "empty"
        }
    }
    static func fromString(str: String) -> ParkLakesObject {
        switch str {
        case "marker":
            return .marker
        case "lake":
            return .lake()
        default:
            return .empty
        }
    }
}

struct ParkLakesGameMove {
    var p = Position()
    var obj = ParkLakesObject()
}
