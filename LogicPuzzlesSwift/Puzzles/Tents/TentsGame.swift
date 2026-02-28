//
//  TentsGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class TentsGame: GridGame<TentsGameState> {
    static let offset = Position.Directions4
    static let offset2 = Position.Directions8
    static let PUZ_UNKNOWN = -1

    var row2hint = [Int]()
    var col2hint = [Int]()
    var pos2tree = [Position]()
    
    init(layout: [String], delegate: TentsGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count - 1, layout[0].length - 1)
        row2hint = Array<Int>(repeating: 0, count: rows)
        col2hint = Array<Int>(repeating: 0, count: cols)
        
        for r in 0..<rows + 1 {
            let str = layout[r]
            for c in 0..<cols + 1 {
                let p = Position(r, c)
                let ch = str[c]
                if ch == "T" {
                    pos2tree.append(p)
                } else if (r == rows) != (c == cols) {
                    let n = ch == " " ? TentsGame.PUZ_UNKNOWN : ch.toInt!
                    if r == rows {
                        col2hint[c] = n
                    } else if c == cols {
                        row2hint[r] = n
                    }
                }
            }
        }
        
        let state = TentsGameState(game: self)
        levelInitialized(state: state)
    }
    
}
