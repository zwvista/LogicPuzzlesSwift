//
//  HolidayIslandObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum HolidayIslandObject: Int {
    case empty, forbidden, marker, hint, water
    init() {
        self = .empty
    }
}

struct HolidayIslandGameMove {
    var p = Position()
    var obj = HolidayIslandObject()
}
