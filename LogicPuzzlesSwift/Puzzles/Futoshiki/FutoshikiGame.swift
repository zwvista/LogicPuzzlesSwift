//
//  FutoshikiGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class FutoshikiGame: GridGame<FutoshikiGameState> {
    static let offset = Position.Directions4

    var objArray = [Character]()
    var pos2hint = [Position: Character]()
    
    init(layout: [String], delegate: FutoshikiGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        objArray = Array<Character>(repeating: " ", count: rows * cols)

        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let p = Position(r, c)
                let ch = str[c]
                self[p] = ch
                if (r % 2 != 0 || c % 2 != 0) && ch != " " {
                    pos2hint[p] = ch
                }
            }
        }

        let state = FutoshikiGameState(game: self)
        levelInitialized(state: state)
    }
    
    subscript(p: Position) -> Character {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> Character {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
}
