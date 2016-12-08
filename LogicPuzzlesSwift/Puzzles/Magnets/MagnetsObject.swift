//
//  MagnetsObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum MagnetsObject: Int {
    case empty
    case positive
    case negative
    case marker
    init() {
        self = .empty
    }
}

struct MagnetsGameMove {
    var p = Position()
    var obj = MagnetsObject()
}

