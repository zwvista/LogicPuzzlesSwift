//
//  CloudsAndClearsObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum CloudsAndClearsObject: Int {
    case empty, marker
    case left, right, horizontal, top, bottom, vertical
    init() {
        self = .empty
    }
    func isCar() -> Bool {
        self != .empty && self != .marker
    }
}

struct CloudsAndClearsGameMove {
    var p = Position()
    var obj = CloudsAndClearsObject()
}

