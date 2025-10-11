//
//  HiddenPathGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class HiddenPathGame: GridGame<HiddenPathGameState> {
    static let offset = [
        Position(-1, 0),
        Position(0, 1),
        Position(1, 0),
        Position(0, -1),
    ]

    var objArray = [Int]()
    var pos2hint = [Position: Int]()

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
        objArray = Array<Int>(repeating: 0, count: rows * cols)

        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let s = str[c * 3..<c * 3 + 2]
                self[r, c] = s == "  " ? 0 : Int(s.trimmed())!
                pos2hint[Position(r, c)] = str[c * 3 + 2].toInt!
            }
        }
        
        let state = HiddenPathGameState(game: self)
        levelInitilized(state: state)
    }
    
}
