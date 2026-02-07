//
//  ZenGardensObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum ZenGardensObject: Int {
    case empty, stone, leaf
    init() {
        self = .empty
    }
}

struct ZenGardensGameMove {
    var p = Position()
    var obj = ZenGardensObject()
}
