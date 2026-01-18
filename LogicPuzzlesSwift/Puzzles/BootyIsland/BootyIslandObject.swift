//
//  BootyIslandObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum BootyIslandObject {
    case empty
    case forbidden
    case hint(state: HintState = .normal)
    case marker
    case treasure(state: AllowedObjectState = .normal)
    init() {
        self = .empty
    }
    func toString() -> String {
        switch self {
        case .marker:
            return "marker"
        case .treasure:
            return "treasure"
        default:
            return "empty"
        }
    }
    static func fromString(str: String) -> BootyIslandObject {
        switch str {
        case "marker":
            return .marker
        case "treasure":
            return .treasure()
        default:
            return .empty
        }
    }
}

struct BootyIslandGameMove {
    var p = Position()
    var obj = BootyIslandObject()
}
