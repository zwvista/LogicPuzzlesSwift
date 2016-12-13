//
//  TentsObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum TentsObject: Int {
    case empty
    case cloud
    case marker
    init() {
        self = .empty
    }
}

struct TentsGameMove {
    var p = Position()
    var obj = TentsObject()
}

