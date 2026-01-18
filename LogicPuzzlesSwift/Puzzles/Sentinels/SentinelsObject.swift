//
//  SentinelsObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum SentinelsObject {
    case empty
    case forbidden
    case hint(state: HintState = .normal)
    case marker
    case tower(state: AllowedObjectState = .normal)
    init() {
        self = .empty
    }
    func toString() -> String {
        switch self {
        case .marker:
            return "marker"
        case .tower:
            return "tower"
        default:
            return "empty"
        }
    }
    static func fromString(str: String) -> SentinelsObject {
        switch str {
        case "marker":
            return .marker
        case "tower":
            return .tower()
        default:
            return .empty
        }
    }
}

struct SentinelsGameMove {
    var p = Position()
    var obj = SentinelsObject()
}
