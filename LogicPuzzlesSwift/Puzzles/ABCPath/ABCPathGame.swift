//
//  ABCPathGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class ABCPathGame: GridGame<ABCPathGameState> {
    static let offset = Position.Directions8

    override func isValid(row: Int, col: Int) -> Bool {
        1..<rows - 1 ~= row && 1..<cols - 1 ~= col
    }

    var objArray = [Character]()
    var ch2pos = [Character: Position]()
    subscript(p: Position) -> Character {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> Character {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    init(layout: [String], delegate: ABCPathGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        objArray = Array<Character>(repeating: " ", count: rows * cols)
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let p = Position(r, c)
                let ch = str[c]
                self[p] = ch
                if r == 0 || r == rows - 1 || c == 0 || c == cols - 1 {
                    ch2pos[ch] = p
                }
            }
        }
        
        let state = ABCPathGameState(game: self)
        levelInitilized(state: state)
    }
    
}
