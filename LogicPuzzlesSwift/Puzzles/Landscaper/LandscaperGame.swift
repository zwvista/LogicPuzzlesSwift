//
//  LandscaperGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class LandscaperGame: GridGame<LandscaperGameState> {
    static let offset = Position.Directions4

    var objArray = [LandscaperObject]()

    init(layout: [String], delegate: LandscaperGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        objArray = Array<LandscaperObject>(repeating: .empty, count: rows * cols)
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                switch str[c] {
                case "T": self[r, c] = .tree
                case "F": self[r, c] = .flower
                default: break
                }
            }
        }
        
        let state = LandscaperGameState(game: self)
        levelInitialized(state: state)
    }
    
    subscript(p: Position) -> LandscaperObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> LandscaperObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
}
