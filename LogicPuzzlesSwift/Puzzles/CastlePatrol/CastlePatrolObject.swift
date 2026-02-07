//
//  CastlePatrolObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum CastlePatrolObject: Int {
    case empty, marker, wall, emptyHint, wallHint
    init() {
        self = .empty
    }
    func isHint() -> Bool {
        self == .emptyHint || self == .wallHint
    }
}

struct CastlePatrolGameMove {
    var p = Position()
    var obj = CastlePatrolObject()
}
