//
//  WallsObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum WallsObject: Int {
    case empty, hint
    case horz, vert
    init() {
        self = .empty
    }
}

struct WallsGameMove {
    var p = Position()
    var obj = WallsObject()
}
