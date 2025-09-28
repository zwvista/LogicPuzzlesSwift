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
    case tent(state: AllowedObjectState)
    case tree(state: AllowedObjectState)
    init() {
        self = .empty
    }
    func toString() -> String {
        switch self {
        case .marker:
            return "marker"
        case .tent:
            return "tent"
        default:
            return "empty"
        }
    }
    static func fromString(str: String) -> HiddenStarsObject {
        switch str {
        case "marker":
            return .marker
        case "tent":
            return .tent(state: .normal)
        default:
            return .empty
        }
    }
}

struct HiddenStarsGameMove {
    var p = Position()
    var obj = HiddenStarsObject()
}

