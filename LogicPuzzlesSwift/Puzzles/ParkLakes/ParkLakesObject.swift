//
//  ParkLakesObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum ParkLakesObject: Int {
    case empty, hint, marker
    case lake
    init() {
        self = .empty
    }
}

struct ParkLakesGameMove {
    var p = Position()
    var obj = ParkLakesObject()
}
