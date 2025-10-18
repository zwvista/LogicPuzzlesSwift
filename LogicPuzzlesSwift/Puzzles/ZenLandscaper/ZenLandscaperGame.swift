//
//  ZenLandscaperGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class ZenLandscaperGame: GridGame<ZenLandscaperGameState> {
    static let offset = Position.Directions8

    var objArray = [Character]()

    subscript(p: Position) -> Character {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> Character {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }

    init(layout: [String], delegate: ZenLandscaperGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        objArray = Array(repeating: " ", count: rows * cols)
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                self[r, c] = str[c]
            }
        }
        
        let state = ZenLandscaperGameState(game: self)
        levelInitialized(state: state)
    }
    
}
