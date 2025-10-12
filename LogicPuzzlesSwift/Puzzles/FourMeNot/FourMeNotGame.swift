//
//  FourMeNotGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class FourMeNotGame: GridGame<FourMeNotGameState> {
    static let offset = Position.Directions4

    var objArray = [FourMeNotObject]()

    init(layout: [String], delegate: FourMeNotGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        objArray = Array<FourMeNotObject>(repeating: .empty, count: rows * cols)
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let p = Position(r, c)
                let ch = str[c]
                switch ch {
                case "F":
                    self[p] = .flower(state: .normal)
                case "B":
                    self[p] = .block
                default:
                    break
                }
            }
        }

        let state = FourMeNotGameState(game: self)
        levelInitilized(state: state)
    }
    
    subscript(p: Position) -> FourMeNotObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> FourMeNotObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
}
