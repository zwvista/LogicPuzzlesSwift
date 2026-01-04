//
//  FourMeNotObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum FourMeNotObject {
    case empty
    case forbidden
    case marker
    case flower(state: AllowedObjectState = .normal)
    case block
    init() {
        self = .empty
    }
    func toString() -> String {
        switch self {
        case .marker:
            return "marker"
        case .flower:
            return "flower"
        default:
            return "empty"
        }
    }
    static func fromString(str: String) -> FourMeNotObject {
        switch str {
        case "marker":
            return .marker
        case "flower":
            return .flower(state: .normal)
        default:
            return .empty
        }
    }
}

struct FourMeNotGameMove {
    var p = Position()
    var obj = FourMeNotObject()
}
