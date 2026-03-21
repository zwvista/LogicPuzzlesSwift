//
//  TrebuchetObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum TrebuchetObject: Int {
    case empty, forbidden, hint, marker
    case target
    init() {
        self = .empty
    }
}

struct TrebuchetGameMove {
    var p = Position()
    var obj = TrebuchetObject()
}
