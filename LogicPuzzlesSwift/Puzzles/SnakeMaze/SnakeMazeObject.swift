//
//  SnakeMazeObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum SnakeMazeObject: Int {
    case empty, forbidden, hint, marker
    case snake1, snake2, snake3, snake4, snake5
    init() {
        self = .empty
    }
    var isSnake: Bool {
        [.snake1, .snake2, .snake3, .snake4, .snake5].contains(self)
    }
    var value: Int {
        isSnake ? rawValue - SnakeMazeObject.snake1.rawValue + 1 : 0
    }
}

struct SnakeMazeHint {
    var num = 0
    var dir = 0
}

struct SnakeMazeGameMove {
    var p = Position()
    var obj = SnakeMazeObject()
}
