//
//  MirrorsObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum MirrorsObject: Int {
    case empty, block
    case upRight, downRight, downLeft, upLeft, horizontal, vertical
    init() {
        self = .empty
    }
}

struct MirrorsGameMove {
    var p = Position()
    var obj = MirrorsObject()
}
