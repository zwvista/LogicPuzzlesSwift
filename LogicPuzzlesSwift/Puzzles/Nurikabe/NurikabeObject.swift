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
    case noMarker, markerAfterWall, markerBeforeWall
    
    static let optionStrings = ["No Marker", "Marker After Wall", "Marker Before Wall"]
}

enum NurikabeObject {
    case empty
    case hint(state: HintState)
    case marker
    case wall
    init() {
        self = .empty
    }
    func toString() -> String {
        switch self {
        case .marker:
            return "marker"
        case .wall:
            return "wall"
        default:
            return "empty"
        }
    }
    static func fromString(str: String) -> NurikabeObject {
        switch str {
        case "marker":
            return .marker
        case "wall":
            return .wall
        default:
            return .empty
        }
    }
}

struct NurikabeGameMove {
    var p = Position()
    var obj = NurikabeObject()
}

