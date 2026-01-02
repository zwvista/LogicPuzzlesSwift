//
//  BusySeasObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum BusySeasObject {
    case empty
    case forbidden
    case hint(state: HintState = .normal)
    case marker
    case lighthouse(state: AllowedObjectState)
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
    static func fromString(str: String) -> BusySeasObject {
        switch str {
        case "marker":
            return .marker
        case "lighthouse":
            return .lighthouse(state: .normal)
        default:
            return .empty
        }
    }
}

struct BusySeasGameMove {
    var p = Position()
    var obj = BusySeasObject()
}
