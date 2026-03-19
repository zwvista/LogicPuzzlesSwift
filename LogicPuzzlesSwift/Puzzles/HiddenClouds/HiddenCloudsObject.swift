//
//  HiddenCloudsObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum HiddenCloudsObject: Int {
    case empty, forbidden, marker
    case cloud
    init() {
        self = .empty
    }
}

struct HiddenCloudsGameMove {
    var p = Position()
    var obj = HiddenCloudsObject()
}
