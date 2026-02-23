//
//  FlowerOMinoObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum FlowerOMinoObject: Int {
    case empty, hedge, center, right, bottom
    case centerRight, centerBottom, rightBottom, centerRightBottom
    init() {
        self = .empty
    }
    var hasCenter: Bool {
        [.center, .centerRight, .centerBottom, .centerRightBottom].contains(self)
    }
    var hasRight: Bool {
        [.right, .centerRight, .rightBottom, .centerRightBottom].contains(self)
    }
    var hasBottom: Bool {
        [.bottom, .centerBottom, .rightBottom, .centerRightBottom].contains(self)
    }
}

struct FlowerOMinoGameMove {
    var p = Position()
    var dir = 0
    var obj = GridLineObject()
}
