//
//  LighthousesObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum LighthousesObject: Int {
    case empty, forbidden, hint, marker
    case lighthouse
    init() {
        self = .empty
    }
}

struct LighthousesGameMove {
    var p = Position()
    var obj = LighthousesObject()
}
