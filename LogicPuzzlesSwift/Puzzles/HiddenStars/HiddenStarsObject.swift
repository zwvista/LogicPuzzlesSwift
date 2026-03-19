//
//  HiddenStarsObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum HiddenStarsObject: Int {
    case empty, forbidden, marker
    case star, arrow
    init() {
        self = .empty
    }
}

struct HiddenStarsGameMove {
    var p = Position()
    var obj = HiddenStarsObject()
}
