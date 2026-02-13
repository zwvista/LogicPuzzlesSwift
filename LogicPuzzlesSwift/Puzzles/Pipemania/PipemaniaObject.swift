//
//  PipemaniaObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum PipemaniaObject: Int {
    case empty, marker, hint
    case upright, downright, leftdown, leftup, horizontal, vertical, cross
    init() {
        self = .empty
    }
}

struct PipemaniaGameMove {
    var p = Position()
    var obj = PipemaniaObject()
}
