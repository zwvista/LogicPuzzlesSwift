//
//  InbetweenSumscrapersGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class InbetweenSumscrapersGame: GridGame<InbetweenSumscrapersGameState> {
    static let offset = Position.Directions4
    static let PUZ_EMPTY = 0
    static let PUZ_SKYSCRAPER = -1
    static let PUZ_UNKNOWN = -1

    var row2hint = [Int]()
    var col2hint = [Int]()
    
    init(layout: [String], delegate: InbetweenSumscrapersGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count - 1, layout[0].length / 2 - 1)
        row2hint = Array<Int>(repeating: 0, count: rows)
        col2hint = Array<Int>(repeating: 0, count: cols)
        
        for r in 0..<rows + 1 {
            let str = layout[r]
            for c in 0..<cols + 1 {
                let isHintRow = r == rows, isHintCol = c == cols
                guard isHintRow != isHintCol else { continue }
                let s = str[c * 2...c * 2 + 1]
                let n = s == "  " ? InbetweenSumscrapersGame.PUZ_UNKNOWN : s.toInt()!
                if isHintRow {
                    col2hint[c] = n
                } else {
                    row2hint[r] = n
                }
            }
        }
        
        let state = InbetweenSumscrapersGameState(game: self)
        levelInitialized(state: state)
    }
    
}
