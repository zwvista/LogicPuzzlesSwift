//
//  LoopAndBlocksGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class LoopAndBlocksGame: GridGame<LoopAndBlocksGameState> {
    static let offset = Position.Directions4
    static let PUZ_ONE: Character = "1"

    var objArray = [Character]()
    var chMax = LoopAndBlocksGame.PUZ_ONE
    var expectedChars = String(LoopAndBlocksGame.PUZ_ONE)
    subscript(p: Position) -> Character {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> Character {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    init(layout: [String], delegate: LoopAndBlocksGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        objArray = Array<Character>(repeating: " ", count: rows * cols)
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let ch = str[c]
                self[r, c] = ch
                if chMax < ch { chMax = ch }
            }
        }
        var ch = LoopAndBlocksGame.PUZ_ONE
        while ch != chMax {
            ch = succ(ch: ch)
            expectedChars.append(ch)
        }
        let state = LoopAndBlocksGameState(game: self)
        levelInitialized(state: state)
    }
    
}
