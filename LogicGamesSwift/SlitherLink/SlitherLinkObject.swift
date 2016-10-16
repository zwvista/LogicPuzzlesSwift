//
//  SlitherLinkObject.swift
//  LogicGamesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum SlitherLinkWallState {
    case normal, complete, error
}

enum SlitherLinkLightbulbState {
    case normal, error
}

enum SlitherLinkMarkerOptions: Int {
    case noMarker, markerAfterLightbulb, markerBeforeLightbulb
    
    static let optionStrings = ["No Marker", "Marker After Lightbulb", "Marker Before Lightbulb"]
}

enum SlitherLinkObjectType {
    case empty
    case lightbulb(state: SlitherLinkLightbulbState)
    case marker
    case wall(state: SlitherLinkWallState)
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
    static func fromString(str: String) -> SlitherLinkObjectType {
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

struct SlitherLinkObject {
    var objType = SlitherLinkObjectType()
    var lightness = 0
}

struct SlitherLinkGameMove {
    var p = Position()
    var objType = SlitherLinkObjectType()
}

