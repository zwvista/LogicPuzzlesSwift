//
//  TheMagicNumberObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum TheMagicNumberObject: Int {
    case empty, forbidden, marker
    case flower, block
    init() {
        self = .empty
    }
}

struct TheMagicNumberGameMove {
    var p = Position()
    var obj = TheMagicNumberObject()
}
