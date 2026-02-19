//
//  MineShipsObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum MineShipsObject: Int {
    case empty, forbidden, hint, marker
    case battleShipTop, battleShipBottom, battleShipLeft, battleShipRight, battleShipMiddle, battleShipUnit
    init() {
        self = .empty
    }
    var isShipPiece: Bool {
        [.battleShipTop, .battleShipBottom, .battleShipLeft, .battleShipRight, .battleShipMiddle, .battleShipUnit].contains(self)
    }
}

struct MineShipsGameMove {
    var p = Position()
    var obj = MineShipsObject()
}

