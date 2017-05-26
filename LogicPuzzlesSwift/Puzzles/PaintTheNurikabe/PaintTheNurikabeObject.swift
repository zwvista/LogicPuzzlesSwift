//
//  PaintTheNurikabeObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum PaintTheNurikabeObject: Int {
    case empty, painted, forbidden, marker
    init() {
        self = .empty
    }
}

struct PaintTheNurikabeGameMove {
    var p = Position()
    var obj = PaintTheNurikabeObject()
}

