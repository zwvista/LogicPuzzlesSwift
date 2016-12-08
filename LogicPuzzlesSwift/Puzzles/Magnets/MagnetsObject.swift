//
//  MagnetsObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum MagnetsMarkerOptions: Int {
    case noMarker, markerAfterCloud, markerBeforeCloud
    
    static let optionStrings = ["No Marker", "Marker After Cloud", "Marker Before Cloud"]
}

enum MagnetsObject: Int {
    case empty
    case cloud
    case marker
    init() {
        self = .empty
    }
}

struct MagnetsGameMove {
    var p = Position()
    var obj = MagnetsObject()
}

