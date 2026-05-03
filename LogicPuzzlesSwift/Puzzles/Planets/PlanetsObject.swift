//
//  PlanetsObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum PlanetsObject: Int {
    case empty
    case none, north, northEast, northWest, east, west, south, southEast, southWest
    case forbidden, marker
    case sun, nebula
    init() {
        self = .empty
    }
}

struct PlanetsGameMove {
    var p = Position()
    var obj = PlanetsObject()
}
