//
//  PointingGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class PointingGame: GridGame<PointingGameState> {
    static let offset = Position.Directions8

    var objArray = [Int]()
    var arrow2rng = [Position: [Position]]()
    subscript(p: Position) -> Int {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> Int {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    init(layout: [String], delegate: PointingGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        objArray = Array(repeating: 0, count: rows * cols)
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let n = str[c].toInt!
                let p = Position(r, c)
                self[p] = n
                let os = PointingGame.offset[n]
                var p2 = p + os
                var rng = [Position]()
                while isValid(p: p2) {
                    rng.append(p2)
                    p2 += os
                }
                arrow2rng[p] = rng
            }
        }
        
        let state = PointingGameState(game: self)
        levelInitialized(state: state)
    }
    
}
