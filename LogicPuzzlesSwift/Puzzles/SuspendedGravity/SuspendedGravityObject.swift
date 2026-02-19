//
//  SuspendedGravityObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum SuspendedGravityObject: Int {
    case empty, forbidden, marker
    case stone
    init() {
        self = .empty
    }
}

struct SuspendedGravityGameMove {
    var p = Position()
    var obj = SuspendedGravityObject()
}
