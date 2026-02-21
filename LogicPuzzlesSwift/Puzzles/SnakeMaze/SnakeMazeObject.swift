//
//  SnakeMazeObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

typealias SnakeMazeObject = [Bool]

struct SnakeMazeHint {
    var num = 0
    var dir = 0
}

struct SnakeMazeGameMove {
    var p = Position()
    var dir = 0
}
