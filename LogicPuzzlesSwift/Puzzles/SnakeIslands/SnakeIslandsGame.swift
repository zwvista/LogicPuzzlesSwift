//
//  SnakeIslandsGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class SnakeIslandsGame: GridGame<SnakeIslandsGameState> {
    static let offset = Position.Directions4

    var objArray = [SnakeIslandsObject]()
    var pos2hint = [Position: Int]()
    
    init(layout: [String], delegate: SnakeIslandsGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        objArray = Array<SnakeIslandsObject>(repeating: .empty, count: rows * cols)

        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let ch = str[c]
                let p = Position(r, c)
                if ch == "S" {
                    self[p] = .wall
                } else if ch != " " {
                    pos2hint[p] = ch.isNumber ? ch.toInt! : Int(ch.asciiValue!) - Int(Character("A").asciiValue!) + 10
                    self[p] = .hint
                }
            }
        }
        
        let state = SnakeIslandsGameState(game: self)
        levelInitialized(state: state)
    }
    
    subscript(p: Position) -> SnakeIslandsObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> SnakeIslandsObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
}
