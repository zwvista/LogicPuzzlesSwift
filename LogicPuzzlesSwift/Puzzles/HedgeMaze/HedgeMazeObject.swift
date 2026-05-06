//
//  HedgeMazeObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum HedgeMazeObject: Int {
    case empty, gate, step, fountain
    case forbidden, marker, hedge
    init() {
        self = .empty
    }
}

struct HedgeMazeGameMove {
    var p = Position()
    var obj = HedgeMazeObject()
}
