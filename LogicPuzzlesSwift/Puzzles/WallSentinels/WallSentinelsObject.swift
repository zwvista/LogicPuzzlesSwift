//
//  WallSentinelsObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum WallSentinelsObject {
    case empty
    case hintWall(tiles: Int, state: HintState)
    case hintLand(tiles: Int, state: HintState)
    case marker
    case wall
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
    static func fromString(str: String) -> WallSentinelsObject {
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

struct WallSentinelsGameMove {
    var p = Position()
    var obj = WallSentinelsObject()
}
