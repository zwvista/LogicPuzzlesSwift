//
//  HitoriObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum HitoriHintState {
    case normal, complete, error
}

enum HitoriMarkerOptions: Int {
    case noMarker, markerAfterDarken, markerBeforeDarken
    
    static let optionStrings = ["No Marker", "Marker After Darken", "Marker Before Darken"]
}

enum HitoriObject: Int {
    case normal
    case darken
    case marker
    init() {
        self = .normal
    }
}

struct HitoriGameMove {
    var p = Position()
    var obj = HitoriObject()
}

