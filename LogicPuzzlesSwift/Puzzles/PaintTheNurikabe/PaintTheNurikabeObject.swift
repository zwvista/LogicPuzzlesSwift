//
//  PaintTheNurikabeObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum PaintTheNurikabeObject {
    case empty
    case forbidden
    case hint(state: HintState)
    case marker
    case painting
    init() {
        self = .empty
    }
    func toString() -> String {
        switch self {
        case .marker:
            return "marker"
        case .painting:
            return "painting"
        default:
            return "empty"
        }
    }
    static func fromString(str: String) -> PaintTheNurikabeObject {
        switch str {
        case "marker":
            return .marker
        case "painting":
            return .painting
        default:
            return .empty
        }
    }
}

struct PaintTheNurikabeGameMove {
    var p = Position()
    var obj = PaintTheNurikabeObject()
}

