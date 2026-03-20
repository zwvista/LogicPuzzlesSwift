//
//  PowerGridObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum PowerGridObject: Int {
    case empty, forbidden, marker
    case post
    init() {
        self = .empty
    }
}

struct PowerGridGameMove {
    var p = Position()
    var obj = PowerGridObject()
}

