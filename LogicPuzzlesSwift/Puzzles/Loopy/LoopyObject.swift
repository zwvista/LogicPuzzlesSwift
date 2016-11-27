//
//  LoopyObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum LoopyMarkerOptions: Int {
    case noMarker, markerAfterLine, markerBeforeLine
    
    static let optionStrings = ["No Marker", "Marker After Line", "Marker Before Line"]
}

enum LoopyObjectOrientation: Int {
    case horizontal
    case vertical
    init() {
        self = .horizontal
    }
}

enum LoopyObject: Int {
    case empty
    case line
    case marker
    init() {
        self = .empty
    }
}

typealias LoopyDotObject = [LoopyObject]

struct LoopyGameMove {
    var p = Position()
    var objOrientation = LoopyObjectOrientation()
    var obj = LoopyObject()
}
