//
//  Square100Game.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class Square100Game: GridGame<Square100GameState> {
    static let offset = Position.Directions4

    var objArray = [String]()
    subscript(p: Position) -> String {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> String {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    init(layout: [String], delegate: Square100GameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        objArray = Array<String>(repeating: "   ", count: rows * cols)
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let ch = str[c]
                self[r, c] = " " + String(ch) + " "
            }
        }

        let state = Square100GameState(game: self)
        levelInitilized(state: state)
    }
    
}
