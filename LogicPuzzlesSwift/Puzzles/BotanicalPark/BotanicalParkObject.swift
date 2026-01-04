//
//  BotanicalParkObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum BotanicalParkObject {
    case empty
    case forbidden
    case marker
    case plant(state: AllowedObjectState = .normal)
    case arrow(state: AllowedObjectState = .normal)
    init() {
        self = .empty
    }
    func toString() -> String {
        switch self {
        case .marker:
            return "marker"
        case .plant:
            return "plant"
        default:
            return "empty"
        }
    }
    static func fromString(str: String) -> BotanicalParkObject {
        switch str {
        case "marker":
            return .marker
        case "plant":
            return .plant(state: .normal)
        default:
            return .empty
        }
    }
}

struct BotanicalParkGameMove {
    var p = Position()
    var obj = BotanicalParkObject()
}

