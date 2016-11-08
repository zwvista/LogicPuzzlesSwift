//
//  NurikabeObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum NurikabeLightbulbState {
    case normal, error
}

enum NurikabeMarkerOptions: Int {
    case noMarker, markerAfterLightbulb, markerBeforeLightbulb
    
    static let optionStrings = ["No Marker", "Marker After Lightbulb", "Marker Before Lightbulb"]
}

enum NurikabeObjectType {
    case empty
    case lightbulb(state: NurikabeLightbulbState)
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
    static func fromString(str: String) -> NurikabeObjectType {
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

struct NurikabeObject {
    var objType = NurikabeObjectType()
    var lightness = 0
}

struct NurikabeGameMove {
    var p = Position()
    var objType = NurikabeObjectType()
}

