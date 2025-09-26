//
//  BranchesObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum BranchesObject {
    case empty
    case hint(state: HintState)
    case marker
    case up
    case right
    case down
    case left
    case horizontal
    case vertical
    init() {
        self = .empty
    }
    func toString() -> String {
        switch self {
        case .marker:
            return "marker"
        case .up:
            return "up"
        case .right:
            return "right"
        case .down:
            return "down"
        case .left:
            return "left"
        case .horizontal:
            return "horizontal"
        case .vertical:
            return "vertical"
        default:
            return "empty"
        }
    }
    static func fromString(str: String) -> BranchesObject {
        switch str {
        case "marker":
            return .marker
        case "up":
            return .up
        case "right":
            return .right
        case "down":
            return .down
        case "left":
            return .left
        case "horizontal":
            return .horizontal
        case "vertical":
            return .vertical
        default:
            return .empty
        }
    }
}

struct BranchesGameMove {
    var p = Position()
    var obj = BranchesObject()
}
