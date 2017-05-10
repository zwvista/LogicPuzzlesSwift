//
//  LightBattleShipsObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum LightBattleShipsObject {
    case empty
    case forbidden
    case hint(state: HintState)
    case marker
    case battleShipTop
    case battleShipBottom
    case battleShipLeft
    case battleShipRight
    case battleShipMiddle
    case battleShipUnit
    init() {
        self = .empty
    }
    func toString() -> String {
        switch self {
        case .marker:
            return "marker"
        case .battleShipTop:
            return "battleShipTop"
        case .battleShipBottom:
            return "battleShipBottom"
        case .battleShipLeft:
            return "battleShipLeft"
        case .battleShipRight:
            return "battleShipRight"
        case .battleShipMiddle:
            return "battleShipMiddle"
        case .battleShipUnit:
            return "battleShipUnit"
        default:
            return "empty"
        }
    }
    static func fromString(str: String) -> LightBattleShipsObject {
        switch str {
        case "marker":
            return .marker
        case "battleShipTop":
            return .battleShipTop
        case "battleShipBottom":
            return .battleShipBottom
        case "battleShipLeft":
            return .battleShipLeft
        case "battleShipRight":
            return .battleShipRight
        case "battleShipMiddle":
            return .battleShipMiddle
        case "battleShipUnit":
            return .battleShipUnit
        default:
            return .empty
        }
    }
}

struct LightBattleShipsGameMove {
    var p = Position()
    var obj = LightBattleShipsObject()
}

