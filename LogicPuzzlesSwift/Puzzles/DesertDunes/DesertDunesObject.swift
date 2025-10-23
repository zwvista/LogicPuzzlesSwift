//
//  DesertDunesObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum DesertDunesObject {
    case empty
    case marker
    case forbidden
    case dune(state: AllowedObjectState = .normal)
    case hint(state: HintState = .normal)
    init() {
        self = .empty
    }
    func toString() -> String {
        switch self {
        case .dune:
            return "dune"
        case .marker:
            return "marker"
        case .hint:
            return "hint"
        case .forbidden:
            return "forbidden"
        default:
            return "empty"
        }
    }
    static func fromString(str: String) -> DesertDunesObject {
        switch str {
        case "dune":
            return .dune()
        case "marker":
            return .marker
        default:
            return .empty
        }
    }
}

struct DesertDunesGameMove {
    var p = Position()
    var obj = DesertDunesObject()
}
