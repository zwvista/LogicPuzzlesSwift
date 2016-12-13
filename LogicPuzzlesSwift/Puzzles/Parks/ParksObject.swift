//
//  ParksObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum ParksObject: Int {
    case empty
    case filled
    case marker
    init() {
        self = .empty
    }
}

struct ParksGameMove {
    var p = Position()
    var obj = ParksObject()
}
