//
//  RomeObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum RomeObject: Int {
    case empty, rome, up, right, down, left
    init() {
        self = .empty
    }
}

struct RomeGameMove {
    var p = Position()
    var obj = RomeObject()
}
