//
//  GardenerObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum GardenerObject: Int {
    case empty, forbidden, marker
    case flower
    init() {
        self = .empty
    }
}

struct GardenerGameMove {
    var p = Position()
    var obj = GardenerObject()
}
