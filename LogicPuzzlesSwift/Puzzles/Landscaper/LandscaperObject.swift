//
//  LandscaperObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum LandscaperObject: Int {
    case empty, tree, flower
    init() {
        self = .empty
    }
}

struct LandscaperGameMove {
    var p = Position()
    var obj = LandscaperObject()
}
