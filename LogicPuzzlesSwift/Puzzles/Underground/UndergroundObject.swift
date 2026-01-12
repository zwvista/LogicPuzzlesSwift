//
//  UndergroundObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum UndergroundObject: Int {
    case empty, marker, forbidden, up, right, down, left
    init() {
        self = .empty
    }
}

struct UndergroundGameMove {
    var p = Position()
    var obj = UndergroundObject()
}
