//
//  HitoriObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum HitoriObject: Int {
    case normal, darken, marker
    init() {
        self = .normal
    }
}

struct HitoriGameMove {
    var p = Position()
    var obj = HitoriObject()
}

