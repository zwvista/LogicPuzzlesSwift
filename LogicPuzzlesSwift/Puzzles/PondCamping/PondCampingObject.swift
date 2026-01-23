//
//  PondCampingObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum PondCampingObject: Int {
    case empty, forbidden, marker, forest, hint
    init() {
        self = .empty
    }
}

struct PondCampingGameMove {
    var p = Position()
    var obj = PondCampingObject()
}
