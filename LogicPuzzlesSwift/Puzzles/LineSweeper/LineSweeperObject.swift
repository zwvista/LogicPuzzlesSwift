//
//  LineSweeperObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum LineSweeperMarkerOptions: Int {
    case noMarker, markerAfterLine, markerBeforeLine
    
    static let optionStrings = ["No Marker", "Marker After Line", "Marker Before Line"]
}

enum LineSweeperObjectOrientation: Int {
    case horizontal
    case vertical
    init() {
        self = .horizontal
    }
}

enum LineSweeperObject: Int {
    case empty
    case line
    case marker
    init() {
        self = .empty
    }
}

typealias LineSweeperDotObject = [LineSweeperObject]

struct LineSweeperGameMove {
    var p = Position()
    var objOrientation = LineSweeperObjectOrientation()
    var obj = LineSweeperObject()
}
