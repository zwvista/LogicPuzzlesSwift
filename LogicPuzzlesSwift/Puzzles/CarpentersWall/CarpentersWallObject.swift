//
//  CarpentersWallObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum CarpentersWallObject {
    case empty
    case corner(tiles: Int, state: HintState)
    case marker
    case wall
    case left(state: HintState)
    case right(state: HintState)
    case up(state: HintState)
    case down(state: HintState)
    init() {
        self = .empty
    }
    func toString() -> String {
        switch self {
        case .marker:
            return "marker"
        case .wall:
            return "wall"
        default:
            return "empty"
        }
    }
    func isHint() -> Bool {
        switch self {
        case .corner, .up, .down, .left, .right:
            return true
        default:
            return false
        }
    }
    static func fromString(str: String) -> CarpentersWallObject {
        switch str {
        case "marker":
            return .marker
        case "wall":
            return .wall
        default:
            return .empty
        }
    }
}

struct CarpentersWallGameMove {
    var p = Position()
    var obj = CarpentersWallObject()
}

