//
//  FingerPointingGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class FingerPointingGame: GridGame<FingerPointingGameState> {
    static let offset = Position.Directions4
    static let PUZ_BLOCK: Character = "O"

    var objArray = [FingerPointingObject]()
    var pos2hint = [Position: Int]()
    
    init(layout: [String], delegate: FingerPointingGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        objArray = Array<FingerPointingObject>(repeating: .empty, count: rows * cols)

        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let p = Position(r, c)
                let ch = str[c]
                if ch.isNumber {
                    self[p] = .hint
                    pos2hint[p] = ch.toInt!
                } else if ch == FingerPointingGame.PUZ_BLOCK {
                    self[p] = .block
                }
            }
        }
        
        let state = FingerPointingGameState(game: self)
        levelInitialized(state: state)
    }
    
    subscript(p: Position) -> FingerPointingObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> FingerPointingObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
}
