//
//  LightenUpObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum LightenUpObjectType: Int {
    case empty, marker
    case lightbulb, wall
    init() {
        self = .empty
    }
}

struct LightenUpObject {
    var objType = LightenUpObjectType()
    var lightness = 0
}

struct LightenUpGameMove {
    var p = Position()
    var objType = LightenUpObjectType()
}
