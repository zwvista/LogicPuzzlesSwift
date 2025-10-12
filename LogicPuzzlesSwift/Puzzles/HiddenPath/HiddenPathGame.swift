//
//  HiddenPathGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class HiddenPathGame: GridGame<HiddenPathGameState> {
    static let offset = Position.Directions8

    var objArray = [Int]()
    var pos2hint = [Position: Int]()
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
        objArray = Array<Int>(repeating: 0, count: maxNum)

        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let p = Position(r, c)
                let s = str[c * 3..<c * 3 + 2]
                self[p] = s == "  " ? 0 : Int(s.trimmed())!
                pos2hint[p] = str[c * 3 + 2].toInt!
            }
        }
        
        let state = HiddenPathGameState(game: self)
        levelInitilized(state: state)
    }
    
}
