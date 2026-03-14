//
//  TapAlikeObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum TapAlikeObject: Int {
    case empty, hint, marker, wall
    init() {
        self = .empty
    }
}

struct TapAlikeGameMove {
    var p = Position()
    var obj = TapAlikeObject()
}
