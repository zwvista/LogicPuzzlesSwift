//
//  MiniLitsObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum MiniLitsObject: Int {
    case empty, forbidden, marker
    case tree
    init() {
        self = .empty
    }
}

struct MiniLitsGameMove {
    var p = Position()
    var obj = MiniLitsObject()
}
