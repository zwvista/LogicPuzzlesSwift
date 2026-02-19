//
//  NooksObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum NooksObject {
    case bread(state: AllowedObjectState = .normal)
    case empty
    case forbidden
    case ham(state: AllowedObjectState = .normal)
    case marker
    init() {
        self = .empty
    }
    func toString() -> String {
        switch self {
        case .bread:
            return "bread"
        case .marker:
            return "marker"
        case .ham:
            return "ham"
        default:
            return "empty"
        }
    }
    static func fromString(str: String) -> NooksObject {
        switch str {
        case "bread":
            return .bread()
        case "marker":
            return .marker
        case "ham":
            return .ham()
        default:
            return .empty
        }
    }
}

struct NooksGameMove {
    var p = Position()
    var obj = NooksObject()
}

