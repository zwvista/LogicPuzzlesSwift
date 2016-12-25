//
//  CloudsObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum CloudsObject: Int {
    case empty
    case cloud
    case forbidden
    case marker
    init() {
        self = .empty
    }
}

struct CloudsGameMove {
    var p = Position()
    var obj = CloudsObject()
}

