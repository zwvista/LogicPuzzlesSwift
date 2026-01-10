//
//  ChocolateObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum ChocolateObject {
    case empty
    case marker
    case forbidden
    case chocolate(state: AllowedObjectState = .normal)
    init() {
        self = .empty
    }
    func toString() -> String {
        switch self {
        case .chocolate:
            return "chocolate"
        case .marker:
            return "marker"
        case .forbidden:
            return "forbidden"
        default:
            return "empty"
        }
    }
    static func fromString(str: String) -> ChocolateObject {
        switch str {
        case "chocolate":
            return .chocolate()
        case "marker":
            return .marker
        default:
            return .empty
        }
    }
}

struct ChocolateGameMove {
    var p = Position()
    var obj = ChocolateObject()
}
