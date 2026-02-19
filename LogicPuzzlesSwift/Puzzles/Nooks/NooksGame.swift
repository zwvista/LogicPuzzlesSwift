//
//  NooksGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class NooksGame: GridGame<NooksGameState> {
    static let offset = Position.Directions4

    var row2hint = [Int]()
    var col2hint = [Int]()
    var pos2post = [Position]()
    
    init(layout: [String], delegate: NooksGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count - 1, layout[0].length - 1)
        row2hint = Array<Int>(repeating: 0, count: rows)
        col2hint = Array<Int>(repeating: 0, count: cols)
        
        for r in 0..<rows + 1 {
            let str = layout[r]
            for c in 0..<cols + 1 {
                let isHintRow = r == rows, isHintCol = c == cols
                guard isHintRow != isHintCol else { continue }
                let ch = str[c]
                let n = ch == " " ? -1 : ch.toInt!
                if isHintRow {
                    col2hint[c] = n
                } else {
                    row2hint[r] = n
                }
            }
        }
        
        let state = NooksGameState(game: self)
        levelInitialized(state: state)
    }
    
}
