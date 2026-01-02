//
//  LiarLiarObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum LiarLiarObject {
    case empty
    case forbidden
    case marked
    case marker
    case hint(state: HintState = .normal)
    init() {
        self = .empty
    }
    func toString() -> String {
        switch self {
        case .marked:
            return "marked"
        case .marker:
            return "marker"
        case .hint:
            return "hint"
        default:
            return "empty"
        }
    }
    static func fromString(str: String) -> LiarLiarObject {
        switch str {
        case "marked":
            return .marked
        case "marker":
            return .marker
        default:
            return .empty
        }
    }
}

struct LiarLiarGameMove {
    var p = Position()
    var obj = LiarLiarObject()
}
