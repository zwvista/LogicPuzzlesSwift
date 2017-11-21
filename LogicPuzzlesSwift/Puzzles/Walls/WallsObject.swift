//
//  WallsObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum WallsObject {
    case empty
    case forbidden
    case horz
    case vert
    case hint(walls: Int, state: HintState)
    init() {
        self = .empty
    }
    func toString() -> String {
        switch self {
        case .horz:
            return "horz"
        case .vert:
            return "vert"
        default:
            return "empty"
        }
    }
    static func fromString(str: String) -> WallsObject {
        switch str {
        case "horz":
            return .horz
        case "vert":
            return .vert
        default:
            return .empty
        }
    }
}

struct WallsGameMove {
    var p = Position()
    var obj = WallsObject()
}
