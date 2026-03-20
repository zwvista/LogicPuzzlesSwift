//
//  LiarLiarObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum LiarLiarObject: Int {
    case empty, forbidden, hint, marker
    case marked
    init() {
        self = .empty
    }
}

struct LiarLiarGameMove {
    var p = Position()
    var obj = LiarLiarObject()
}
