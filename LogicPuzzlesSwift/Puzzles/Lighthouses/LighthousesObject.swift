//
//  LighthousesObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum LighthousesObject {
    case empty
    case forbidden
    case hint(state: HintState = .normal)
    case marker
    case lighthouse(state: AllowedObjectState = .normal)
    init() {
        self = .empty
    }
    func toString() -> String {
        switch self {
        case .marker:
            return "marker"
        case .lighthouse:
            return "lighthouse"
        default:
            return "empty"
        }
    }
    static func fromString(str: String) -> LighthousesObject {
        switch str {
        case "marker":
            return .marker
        case "lighthouse":
            return .lighthouse()
        default:
            return .empty
        }
    }
}

struct LighthousesGameMove {
    var p = Position()
    var obj = LighthousesObject()
}
