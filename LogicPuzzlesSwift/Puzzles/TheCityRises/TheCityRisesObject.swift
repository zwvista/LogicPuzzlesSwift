//
//  TheCityRisesObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum TheCityRisesObject: Int {
    case empty, forbidden, marker
    case block
    init() {
        self = .empty
    }
}

struct TheCityRisesGameMove {
    var p = Position()
    var obj = TheCityRisesObject()
}
