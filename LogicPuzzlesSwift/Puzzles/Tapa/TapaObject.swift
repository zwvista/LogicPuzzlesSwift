//
//  TapaObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum TapaObject: Int {
    case empty, hint, marker, wall
    init() {
        self = .empty
    }
}

struct TapaGameMove {
    var p = Position()
    var obj = TapaObject()
}
