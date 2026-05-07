//
//  TheGreyLabyrinthGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class TheGreyLabyrinthGame: GridGame<TheGreyLabyrinthGameState> {
    static let offset = Position.Directions4
    static let chars = " T^>v<"

    var objArray = [TheGreyLabyrinthObject]()
    var treasure = Position.Zero

    init(layout: [String], delegate: TheGreyLabyrinthGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        objArray = Array<TheGreyLabyrinthObject>(repeating: .empty, count: rows * cols)
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let p = Position(r, c)
                let ch = str[c]
                self[p] = TheGreyLabyrinthObject(rawValue: TheGreyLabyrinthGame.chars.getIndexOf(ch)!)!
                if ch == "T" {
                    treasure = p
                }
            }
        }

        let state = TheGreyLabyrinthGameState(game: self)
        levelInitialized(state: state)
    }
    
    subscript(p: Position) -> TheGreyLabyrinthObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> TheGreyLabyrinthObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
}
