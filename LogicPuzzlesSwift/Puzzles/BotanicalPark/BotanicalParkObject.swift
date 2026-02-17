//
//  BotanicalParkObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum BotanicalParkObject: Int {
    case empty, forbidden, marker
    case plant, arrow
    init() {
        self = .empty
    }
}

struct BotanicalParkGameMove {
    var p = Position()
    var obj = BotanicalParkObject()
}

