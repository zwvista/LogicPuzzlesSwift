//
//  PipemaniaGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class PipemaniaGame: GridGame<PipemaniaGameState> {
    static let offset = Position.Directions4

    var objArray = [PipemaniaObject]()

    init(layout: [String], delegate: PipemaniaGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        objArray = Array<PipemaniaObject>(repeating: .empty, count: rows * cols)
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let ch = str[c]
                self[r, c] = switch ch {
                case "3": .upright
                case "6": .downright
                case "C": .leftdown
                case "9": .leftup
                case "A": .horizontal
                case "5": .vertical
                default: .empty
                }
             }
        }

        let state = PipemaniaGameState(game: self)
        levelInitialized(state: state)
    }
    
    subscript(p: Position) -> PipemaniaObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> PipemaniaObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
}
