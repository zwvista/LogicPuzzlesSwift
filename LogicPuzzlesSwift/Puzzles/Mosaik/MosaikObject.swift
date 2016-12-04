//
//  MosaikObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum MosaikMarkerOptions: Int {
    case noMarker, markerAfterLine, markerBeforeLine
    
    static let optionStrings = ["No Marker", "Marker After Line", "Marker Before Line"]
}

enum MosaikObjectOrientation: Int {
    case horizontal
    case vertical
    init() {
        self = .horizontal
    }
}

enum MosaikObject: Int {
    case empty
    case line
    case marker
    init() {
        self = .empty
    }
}

typealias MosaikDotObject = [MosaikObject]

struct MosaikGameMove {
    var p = Position()
    var dir = 0
    var obj = MosaikObject()
}
