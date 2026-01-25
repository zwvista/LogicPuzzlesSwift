//
//  FingerPointingObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum FingerPointingObject: Int {
    case empty, block, hint, up, right, down, left
    init() {
        self = .empty
    }
}

struct FingerPointingGameMove {
    var p = Position()
    var obj = FingerPointingObject()
}
