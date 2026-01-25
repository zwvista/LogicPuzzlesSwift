//
//  InbetweenNurikabeObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum InbetweenNurikabeObject: Int {
    case empty, hint, marker, wall
    init() {
        self = .empty
    }
}

struct InbetweenNurikabeGameMove {
    var p = Position()
    var obj = InbetweenNurikabeObject()
}
