//
//  LitsObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum LitsObject {
    case empty
    case forbidden
    case marker
    case tree(state: AllowedObjectState)
    init() {
        self = .empty
    }
    func toString() -> String {
        switch self {
        case .marker:
            return "marker"
        case .tree:
            return "tree"
        default:
            return "empty"
        }
    }
    static func fromString(str: String) -> LitsObject {
        switch str {
        case "marker":
            return .marker
        case "tree":
            return .tree(state: .normal)
        default:
            return .empty
        }
    }
}

struct LitsGameMove {
    var p = Position()
    var obj = LitsObject()
}
