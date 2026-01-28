//
//  TrafficWardenObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

typealias TrafficWardenObject = [Bool]

struct TrafficWardenHint {
    var light: Character = " "
    var len: Int = 0
}

struct TrafficWardenGameMove {
    var p = Position()
    var dir = 0
}
