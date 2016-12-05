//
//  MosaikObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum MosaikMarkerOptions: Int {
    case noMarker, markerAfterFill, markerBeforeFill
    
    static let optionStrings = ["No Marker", "Marker After Fill", "Marker Before Fill"]
}

enum MosaikObject: Int {
    case empty
    case filled
    case marker
    init() {
        self = .empty
    }
}

struct MosaikGameMove {
    var p = Position()
    var obj = MosaikObject()
}
