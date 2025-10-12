//
//  DigitalBattleShipsGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class DigitalBattleShipsGame: GridGame<DigitalBattleShipsGameState> {
    static let offset = Position.Directions8

    var objArray = [Int]()
    var row2hint = [Int]()
    var col2hint = [Int]()
    
    init(layout: [String], delegate: DigitalBattleShipsGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count - 1, layout[0].length / 2 - 1)
        objArray = Array<Int>(repeating: 0, count: rows * cols)
        row2hint = Array<Int>(repeating: 0, count: rows)
        col2hint = Array<Int>(repeating: 0, count: cols)
        
        for r in 0..<rows + 1 {
            let str = layout[r]
            for c in 0..<cols + 1 {
                let s = str[c * 2...c * 2 + 1]
                guard s != "  " else {continue}
                let n = s.toInt()!
                if r == rows {
                    col2hint[c] = n
                } else if c == cols {
                    row2hint[r] = n
                } else {
                    self[r, c] = n
                }
            }
        }
        
        let state = DigitalBattleShipsGameState(game: self)
        levelInitilized(state: state)
    }
    
    subscript(p: Position) -> Int {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> Int {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
}
