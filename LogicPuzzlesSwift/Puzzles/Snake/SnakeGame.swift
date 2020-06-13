//
//  SnakeGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class SnakeGame: GridGame<SnakeGameViewController> {
    static let offset = [
        Position(-1, 0),
        Position(0, 1),
        Position(1, 0),
        Position(0, -1),
    ]

    var row2hint = [Int]()
    var col2hint = [Int]()
    var pos2snake = [Position]()
    
    init(layout: [String], delegate: SnakeGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count - 1, layout[0].length - 1)
        row2hint = Array<Int>(repeating: -1, count: rows)
        col2hint = Array<Int>(repeating: -1, count: cols)
        
        for r in 0..<rows + 1 {
            let str = layout[r]
            for c in 0..<cols + 1 {
                let p = Position(r, c)
                let ch = str[c]
                switch ch {
                case "S":
                    pos2snake.append(p)
                case "0"..."9":
                    let n = ch.toInt!
                    if r == rows {
                        col2hint[c] = n
                    } else if c == cols {
                        row2hint[r] = n
                    }
                default:
                    if r == rows && c == cols {
                        // 
                    } else if r == rows {
                        col2hint[c] = -1
                    } else if c == cols {
                        row2hint[r] = -1
                    }
                }
            }
        }
        
        let state = SnakeGameState(game: self)
        levelInitilized(state: state)
    }
    
    func switchObject(move: inout SnakeGameMove) -> Bool {
        changeObject(move: &move, f: {state, move in state.switchObject(move: &move)})
    }
    
    func setObject(move: inout SnakeGameMove) -> Bool {
        changeObject(move: &move, f: {state, move in state.setObject(move: &move)})
    }
    
}
