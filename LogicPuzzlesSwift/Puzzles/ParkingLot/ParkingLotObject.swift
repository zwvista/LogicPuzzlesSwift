//
//  ParkingLotObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum ParkingLotObject: Int {
    case empty, forbidden, marker
    case left, right, horizontal, top, bottom, vertical
    init() {
        self = .empty
    }
}

struct ParkingLotGameMove {
    var p = Position()
    var obj = ParkingLotObject()
}

