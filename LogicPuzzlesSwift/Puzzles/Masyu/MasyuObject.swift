//
//  MasyuObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum MasyuMarkerOptions: Int {
    case noMarker, markerAfterLine, markerBeforeLine
    
    static let optionStrings = ["No Marker", "Marker After Line", "Marker Before Line"]
}

enum MasyuObjectOrientation: Int {
    case horizontal
    case vertical
    init() {
        self = .horizontal
    }
}

enum MasyuObject: Int {
    case empty
    case line
    case marker
    init() {
        self = .empty
    }
}

typealias MasyuDotObject = [MasyuObject]

struct MasyuGameMove {
    var p = Position()
    var objOrientation = MasyuObjectOrientation()
    var obj = MasyuObject()
}
