//
//  CloudsAndClearsObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum CloudsAndClearsObject: Int {
    case empty, marker
    case cloud
    init() {
        self = .empty
    }
    var isCloud: Bool { self == .cloud }
}

struct CloudsAndClearsGameMove {
    var p = Position()
    var obj = CloudsAndClearsObject()
}

