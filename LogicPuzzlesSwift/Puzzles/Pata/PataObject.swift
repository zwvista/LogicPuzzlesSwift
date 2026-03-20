//
//  PataObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum PataObject: Int {
    case empty, hint, marker
    case wall
    init() {
        self = .empty
    }
}

struct PataGameMove {
    var p = Position()
    var obj = PataObject()
}

