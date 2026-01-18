//
//  GardenerObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum GardenerObject {
    case empty
    case forbidden
    case marker
    case flower(state: AllowedObjectState = .normal)
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
    static func fromString(str: String) -> GardenerObject {
        switch str {
        case "marker":
            return .marker
        case "flower":
            return .flower()
        default:
            return .empty
        }
    }
}

struct GardenerGameMove {
    var p = Position()
    var obj = GardenerObject()
}
