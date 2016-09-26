//
//  GameObject.swift
//  LightenUp
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum WallState {
    case normal, complete, error
}

enum LightbulbState {
    case normal, error
}

enum GameObjectType {
    case empty
    case lightbulb(state: LightbulbState)
    case marker
    case wall(lightbulbs: Int, state: WallState)
    init() {
        self = .empty
    }
    func toString() -> String {
        switch self {
        case .lightbulb:
            return "lightbulb"
        case .marker:
            return "marker"
        default:
            return "empty"
        }
    }
    static func fromString(str: String) -> GameObjectType {
        switch str {
        case "lightbulb":
            return .lightbulb(state: .normal)
        case "marker":
            return .marker
        default:
            return .empty
        }
    }
}

struct GameObject {
    var objType = GameObjectType()
    var lightness = 0
}

let offset = [
    Position(-1, 0),
    Position(0, 1),
    Position(1, 0),
    Position(0, -1),
];

struct GameMove {
    var p = Position()
    var objType = GameObjectType()
}

