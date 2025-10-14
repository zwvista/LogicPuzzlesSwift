//
//  HiddenPathGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class HiddenPathGame: GridGame<HiddenPathGameState> {
    static let PUZ_UNKNOWN = 0
    static let PUZ_FORBIDDEN = -1
    static let offset = Position.Directions8

    var objArray = [Int]()
    var pos2hint = [Position: Int]()
    var pos2range = [Position: [Position]]()
    var maxNum = 0

    subscript(p: Position) -> Int {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> Int {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    init(layout: [String], delegate: HiddenPathGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length / 3)
        maxNum = rows * cols
        objArray = Array(repeating: 0, count: maxNum)

        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let p = Position(r, c)
                let s = str[c * 3..<c * 3 + 2]
                self[p] = s == "  " ? 0 : Int(s.trimmed())!
                pos2hint[p] = str[c * 3 + 2].toInt!
            }
        }
        
        for (p, hint) in pos2hint {
            var range = [Position]()
            if hint != 8 {
                let os = HiddenPathGame.offset[hint]
                var p2 = p + os
                while isValid(p: p2) {
                    range.append(p2)
                    p2 += os
                }
            }
            pos2range[p] = range
        }
        
        let state = HiddenPathGameState(game: self)
        levelInitialized(state: state)
    }
    
}
