//
//  NorthPoleFishingObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum NorthPoleFishingObject: Int {
    case empty, block, hole
}

struct NorthPoleFishingGameMove {
    var p = Position()
    var dir = 0
    var obj = GridLineObject()
}
