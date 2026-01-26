//
//  MineSlitherObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum MineSlitherObject: Int {
    case empty, forbidden, marker
    case wall
    init() {
        self = .empty
    }
}

struct MineSlitherGameMove {
    var p = Position()
    var obj = MineSlitherObject()
}

