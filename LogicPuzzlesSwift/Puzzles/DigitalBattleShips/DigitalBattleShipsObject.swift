//
//  DigitalBattleShipsObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum DigitalBattleShipsObject: Int {
    case empty, forbidden, marker
    case battleShipTop, battleShipBottom, battleShipLeft, battleShipRight, battleShipMiddle, battleShipUnit
    init() {
        self = .empty
    }
}

struct DigitalBattleShipsGameMove {
    var p = Position()
    var obj = DigitalBattleShipsObject()
}

