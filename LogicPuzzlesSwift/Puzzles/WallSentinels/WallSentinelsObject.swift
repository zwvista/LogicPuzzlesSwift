//
//  WallSentinelsObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum WallSentinelsObject: Int {
    case empty, marker
    case hintWall, hintLand, wall
    init() {
        self = .empty
    }
}

struct WallSentinelsGameMove {
    var p = Position()
    var obj = WallSentinelsObject()
}
