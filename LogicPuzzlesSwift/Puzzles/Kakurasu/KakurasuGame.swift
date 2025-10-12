//
//  KakurasuGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class KakurasuGame: GridGame<KakurasuGameState> {
    static let offset = Position.Directions4

    override func isValid(row: Int, col: Int) -> Bool {
        1..<rows - 1 ~= row && 1..<cols - 1 ~= col
    }

    var row2hint = [Int]()
    var col2hint = [Int]()
    
    init(layout: [String], delegate: KakurasuGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length / 2)
        row2hint = Array<Int>(repeating: 0, count: rows * 2)
        col2hint = Array<Int>(repeating: 0, count: cols * 2)

        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let s = str[c * 2...c * 2 + 1]
                guard s != "  " else {continue}
                let n = s.toInt()!
                if r == 0 || r == rows - 1 {
                    col2hint[c * 2 + (r == 0 ? 0 : 1)] = n
                } else if c == 0 || c == cols - 1 {
                    row2hint[r * 2 + (c == 0 ? 0 : 1)] = n
                }
            }
        }
        
        let state = KakurasuGameState(game: self)
        levelInitilized(state: state)
    }
    
}
