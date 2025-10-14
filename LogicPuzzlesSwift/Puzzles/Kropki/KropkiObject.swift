//
//  KropkiObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum KropkiHint: Int {
    case none, consecutive, twice
    init() {
        self = .none
    }
}

struct KropkiGameMove {
    var p = Position()
    var obj = 0
}

