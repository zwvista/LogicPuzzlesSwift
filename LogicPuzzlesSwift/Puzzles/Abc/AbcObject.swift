//
//  AbcObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum AbcMarkerOptions: Int {
    case noMarker, markerAfterDarken, markerBeforeDarken
    
    static let optionStrings = ["No Marker", "Marker After Darken", "Marker Before Darken"]
}

enum AbcObject: Int {
    case normal
    case darken
    case marker
    init() {
        self = .normal
    }
}

struct AbcGameMove {
    var p = Position()
    var obj = AbcObject()
}

