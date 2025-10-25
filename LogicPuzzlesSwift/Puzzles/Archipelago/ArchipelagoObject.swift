//
//  ArchipelagoObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum ArchipelagoObject {
    case empty
    case marker
    case water
    case hint(state: HintState = .normal)
    init() {
        self = .empty
    }
    func toString() -> String {
        switch self {
        case .marker:
            return "marker"
        case .water:
            return "water"
        case .hint:
            return "hint"
        default:
            return "empty"
        }
    }
    static func fromString(str: String) -> ArchipelagoObject {
        switch str {
        case "marker":
            return .marker
        case "water":
            return .water
        default:
            return .empty
        }
    }
}

struct ArchipelagoGameMove {
    var p = Position()
    var obj = ArchipelagoObject()
}
