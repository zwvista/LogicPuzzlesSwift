//
//  CastleBaileyObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum CastleBaileyObject: Int {
    case empty, forbidden, marker
    case wall
    init() {
        self = .empty
    }
}

struct CastleBaileyGameMove {
    var p = Position()
    var obj = CastleBaileyObject()
}

