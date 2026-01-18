//
//  ParksObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum ParksObject {
    case empty
    case forbidden
    case marker
    case tree(state: AllowedObjectState = .normal)
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
    static func fromString(str: String) -> ParksObject {
        switch str {
        case "marker":
            return .marker
        case "tree":
            return .tree()
        default:
            return .empty
        }
    }
}

struct ParksGameMove {
    var p = Position()
    var obj = ParksObject()
}
