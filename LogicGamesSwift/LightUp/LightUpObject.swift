//
//  LightUpObject.swift
//  LogicGamesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum LightUpWallState {
    case normal, complete, error
}

enum LightUpLightbulbState {
    case normal, error
}

enum LightUpMarkerOptions: Int {
    case noMarker, markerAfterLightbulb, markerBeforeLightbulb
    
    static let optionStrings = ["No Marker", "Marker After Lightbulb", "Marker Before Lightbulb"]
}

enum LightUpObjectType {
    case empty
    case lightbulb(state: LightUpLightbulbState)
    case marker
    case wall(lightbulbs: Int, state: LightUpWallState)
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
    static func fromString(str: String) -> LightUpObjectType {
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

struct LightUpObject {
    var objType = LightUpObjectType()
    var lightness = 0
}

let offset = [
    Position(-1, 0),
    Position(0, 1),
    Position(1, 0),
    Position(0, -1),
];

struct LightUpGameMove {
    var p = Position()
    var objType = LightUpObjectType()
}

