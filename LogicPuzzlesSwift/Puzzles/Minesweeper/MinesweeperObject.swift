//
//  MinesweeperObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum MinesweeperObject: Int {
    case empty, forbidden, hint, marker
    case mine
    init() {
        self = .empty
    }
}

struct MinesweeperGameMove {
    var p = Position()
    var obj = MinesweeperObject()
}
