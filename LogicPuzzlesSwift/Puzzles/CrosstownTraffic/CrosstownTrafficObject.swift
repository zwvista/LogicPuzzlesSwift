//
//  CrosstownTrafficObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum CrosstownTrafficObject {
    case empty
    case gem(state: AllowedObjectState = .normal)
    case hint(state: HintState = .normal)
    case marker
    case pebble
    init() {
        self = .empty
    }
    func toString() -> String {
        switch self {
        case .marker:
            return "marker"
        case .pebble:
            return "pebble"
        case .gem:
            return "gem"
        default:
            return "empty"
        }
    }
    static func fromString(str: String) -> CrosstownTrafficObject {
        switch str {
        case "marker":
            return .marker
        case "pebble":
            return .pebble
        case "gem":
            return .gem()
        default:
            return .empty
        }
    }
}

struct CrosstownTrafficGameMove {
    var p = Position()
    var obj = CrosstownTrafficObject()
}
