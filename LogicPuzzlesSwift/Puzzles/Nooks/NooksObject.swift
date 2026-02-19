//
//  NooksObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum NooksObject: Int {
    case empty, hint, marker
    case hedge
    init() {
        self = .empty
    }
    var isHedge: Bool { self == .hedge }
    var isEmpty: Bool { self != .hedge }
}

struct NooksGameMove {
    var p = Position()
    var obj = NooksObject()
}
