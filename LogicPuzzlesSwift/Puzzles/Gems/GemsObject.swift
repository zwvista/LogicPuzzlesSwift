//
//  GemsObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum GemsObject: Int {
    case empty, forbidden, marker, gem, pebble
    init() {
        self = .empty
    }
}

struct GemsGameMove {
    var p = Position()
    var obj = GemsObject()
}
