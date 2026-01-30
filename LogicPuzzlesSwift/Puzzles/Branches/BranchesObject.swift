//
//  BranchesObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum BranchesObject: Int {
    case empty, hint, up, right, down, left, horizontal, vertical
    init() {
        self = .empty
    }
}

struct BranchesGameMove {
    var p = Position()
    var obj = BranchesObject()
}
