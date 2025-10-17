//
//  ThermometersObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum ThermometersPart {
    case bulb
    case body
    case end
}

enum ThermometersObject {
    case empty
    case forbidden
    case filled
    case marker
    init() {
        self = .empty
    }
    func toString() -> String {
        switch self {
        case .filled:
            return "filled"
        case .marker:
            return "marker"
        default:
            return "empty"
        }
    }
    static func fromString(str: String) -> ThermometersObject {
        switch str {
        case "filled":
            return .filled
        case "marker":
            return .marker
        default:
            return .empty
        }
    }
}

struct ThermometersGameMove {
    var p = Position()
    var obj = ThermometersObject()
}

