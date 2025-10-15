//
//  TurnTwiceGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class TurnTwiceGame: GridGame<TurnTwiceGameState> {
    static let offset = Position.Directions4

    var objArray = [TurnTwiceObject]()

    init(layout: [String], delegate: TurnTwiceGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        objArray = Array<TurnTwiceObject>(repeating: .empty, count: rows * cols)
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let p = Position(r, c)
                let ch = str[c]
                if ch == "S" {
                    self[p] = .signpost(state: .normal)
                }
            }
        }

        let state = TurnTwiceGameState(game: self)
        levelInitialized(state: state)
    }
    
    subscript(p: Position) -> TurnTwiceObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> TurnTwiceObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
}
