//
//  CarpentersSquareObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum CarpentersSquareHint {
    case empty
    case corner(tiles: Int)
    case left
    case right
    case up
    case down
    init() {
        self = .empty
    }
    func isHint() -> Bool {
        switch self {
        case .corner, .up, .down, .left, .right:
            return true
        default:
            return false
        }
    }
}

struct CarpentersSquareGameMove {
    var p = Position()
    var dir = 0
    var obj = GridLineObject()
}
