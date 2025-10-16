//
//  ThermometersObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum ThermometersObject {
    case empty
    case forbidden
    case marker
    case star(state: AllowedObjectState)
    case arrow(state: AllowedObjectState)
    init() {
        self = .empty
    }
    func toString() -> String {
        switch self {
        case .marker:
            return "marker"
        case .star:
            return "star"
        default:
            return "empty"
        }
    }
    static func fromString(str: String) -> ThermometersObject {
        switch str {
        case "marker":
            return .marker
        case "star":
            return .star(state: .normal)
        default:
            return .empty
        }
    }
}

struct ThermometersGameMove {
    var p = Position()
    var obj = ThermometersObject()
}

