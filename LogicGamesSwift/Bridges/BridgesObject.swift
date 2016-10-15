//
//  BridgesObject.swift
//  LogicGamesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum BridgesIslandState {
    case normal, complete, error
}

enum BridgesObject {
    case empty
    case island(state: BridgesIslandState, bridges: [Int])
    case bridge
    init() {
        self = .empty
    }
}

struct BridgesGameMove {
    var pFrom = Position()
    var pTo = Position()
}

