//
//  FussyWaiterGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class FussyWaiterGame: GridGame<FussyWaiterGameState> {
    static let offset = Position.Directions4

    var objArray = [FussyWaiterObject]()

    init(layout: [String], delegate: FussyWaiterGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        objArray = Array<FussyWaiterObject>(repeating: .empty, count: rows * cols)
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let p = Position(r, c)
                let ch = str[c]
                switch ch {
                case "F":
                    self[p] = .flower()
                case "B":
                    self[p] = .block
                default:
                    break
                }
            }
        }

        let state = FussyWaiterGameState(game: self)
        levelInitialized(state: state)
    }
    
    subscript(p: Position) -> FussyWaiterObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> FussyWaiterObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
}
