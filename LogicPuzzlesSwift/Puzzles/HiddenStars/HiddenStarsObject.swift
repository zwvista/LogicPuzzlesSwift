//
//  HiddenStarsObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum HiddenStarsObject {
    case empty
    case forbidden
    case marker
    case star(state: AllowedObjectState = .normal)
    case arrow(state: AllowedObjectState = .normal)
    init() {
        self = .empty
    }
    func toString() -> String {
        switch self {
        case .marker:
            return "marker"
        case .star:
            return "star"
        default:
            return "empty"
        }
    }
    static func fromString(str: String) -> HiddenStarsObject {
        switch str {
        case "marker":
            return .marker
        case "star":
            return .star()
        default:
            return .empty
        }
    }
}

struct HiddenStarsGameMove {
    var p = Position()
    var obj = HiddenStarsObject()
}

