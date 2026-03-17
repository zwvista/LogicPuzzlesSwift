//
//  BootyIslandObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum BootyIslandObject: Int {
    case empty, forbidden, hint, marker
    case treasure
    init() {
        self = .empty
    }
}

struct BootyIslandGameMove {
    var p = Position()
    var obj = BootyIslandObject()
}
