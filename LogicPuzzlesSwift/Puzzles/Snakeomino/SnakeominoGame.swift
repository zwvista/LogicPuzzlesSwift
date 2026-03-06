//
//  SnakeominoGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class SnakeominoGame: GridGame<SnakeominoGameState> {
    static let offset = Position.Directions4
    static let PUZ_EMPTY = 0
    static let PUZ_END: Character = "O"
    static let PUZ_NOT_END: Character = "X"
    
    var objArray = [Int]()
    var pos2hint = [Position: Character]()
    var nMax = 2

    init(layout: [String], delegate: SnakeominoGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length / 2)
        objArray = Array<Int>(repeating: 0, count: rows * cols)
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let p = Position(r, c)
                let (ch1, ch2) = (str[c * 2], str[c * 2 + 1])
                let n = ch1 == " " ? SnakeominoGame.PUZ_EMPTY : ch1.toInt!
                self[p] = n
                if nMax < n { nMax = n }
                if ch2 != " " { pos2hint[p] = ch2 }
            }
        }
        
        let state = SnakeominoGameState(game: self)
        levelInitialized(state: state)
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
