//
//  TentsObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum TentsObject {
    case empty
    case forbidden
    case marker
    case tent(state: AllowedObjectState)
    case tree
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
    static func fromString(str: String) -> TentsObject {
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

struct TentsGameMove {
    var p = Position()
    var obj = TentsObject()
}

