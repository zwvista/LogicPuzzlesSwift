//
//  MinesweeperObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum MinesweeperObject {
    case empty
    case forbidden
    case hint(state: HintState = .normal)
    case marker
    case mine
    init() {
        self = .empty
    }
    func toString() -> String {
        switch self {
        case .marker:
            return "marker"
        case .mine:
            return "mine"
        default:
            return "empty"
        }
    }
    static func fromString(str: String) -> MinesweeperObject {
        switch str {
        case "marker":
            return .marker
        case "mine":
            return .mine
        default:
            return .empty
        }
    }
}

struct MinesweeperGameMove {
    var p = Position()
    var obj = MinesweeperObject()
}
