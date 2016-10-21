//
//  SlitherLinkObject.swift
//  LogicGamesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum SlitherLinkHintState {
    case normal, complete, error
}

enum SlitherLinkMarkerOptions: Int {
    case noMarker, markerAfterLine, markerBeforeLine
    
    static let optionStrings = ["No Marker", "Marker After Line", "Marker Before Line"]
}

enum SlitherLinkObjectOrientation: Int {
    case horizontal
    case vertical
    init() {
        self = .horizontal
    }
}

enum SlitherLinkObject: Int {
    case empty
    case line
    case marker
    init() {
        self = .empty
    }
}

typealias SlitherLinkDotObject = [SlitherLinkObject]

struct SlitherLinkGameMove {
    var p = Position()
    var objOrientation = SlitherLinkObjectOrientation()
    var obj = SlitherLinkObject()
}
