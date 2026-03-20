//
//  RabbitsObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum RabbitsObject: Int {
    case empty, forbidden, hint, marker
    case rabbit, tree
    init() {
        self = .empty
    }
}

struct RabbitsGameMove {
    var p = Position()
    var obj = RabbitsObject()
}
