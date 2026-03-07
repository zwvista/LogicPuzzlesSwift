//
//  LandscapesObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum LandscapesObject: Int {
    case empty, tree, sand, rock, water
    init() {
        self = .empty
    }
}

struct LandscapesGameMove {
    var p = Position()
    var obj = LandscapesObject()
}
