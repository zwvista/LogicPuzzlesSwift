//
//  FourMeNotObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum FourMeNotObject: Int {
    case empty, forbidden, marker
    case flower, block
    init() {
        self = .empty
    }
}

struct FourMeNotGameMove {
    var p = Position()
    var obj = FourMeNotObject()
}
