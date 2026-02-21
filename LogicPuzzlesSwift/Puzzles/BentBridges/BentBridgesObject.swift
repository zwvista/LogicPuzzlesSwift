//
//  BentBridgesObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum BentBridgesObject {
    case empty
    case island(state: HintState, bridges: [Int])
    case bridge
    init() {
        self = .empty
    }
}

class BentBridgesIslandInfo {
    var bridges = 0
    var neighbors: [Position?] = [nil, nil, nil, nil]
    init(b: Int) {
        bridges = b
    }
}

struct BentBridgesGameMove {
    var pFrom = Position()
    var pTo = Position()
}
