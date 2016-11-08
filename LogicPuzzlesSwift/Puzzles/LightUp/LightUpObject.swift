//
//  LightUpObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

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
    case wall(state: HintState)
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

struct LightUpGameMove {
    var p = Position()
    var objType = LightUpObjectType()
}

