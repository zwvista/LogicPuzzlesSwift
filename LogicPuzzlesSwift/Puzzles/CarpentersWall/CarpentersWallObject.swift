//
//  CarpentersWallObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum CarpentersWallObject: Int {
    case empty, marker
    case corner, wall
    case left, right, up, down
    init() {
        self = .empty
    }
    var isHint: Bool {
        switch self {
        case .corner, .up, .down, .left, .right: true
        default: false
        }
    }
}

struct CarpentersWallGameMove {
    var p = Position()
    var obj = CarpentersWallObject()
}

