//
//  FenceLitsGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class FenceLitsGame: GridGame<FenceLitsGameState> {
    static let offset = Position.Directions4
    static let offset2 = [
        Position(0, 0),
        Position(1, 1),
        Position(1, 1),
        Position(0, 0),
    ]
    static let dirs = [1, 0, 3, 2]

    static let tetrominoes = [
        // L
        [Position(0, 0), Position(1, 0), Position(2, 0), Position(2, 1)],
        [Position(0, 1), Position(1, 1), Position(2, 0), Position(2, 1)],
        [Position(0, 0), Position(0, 1), Position(0, 2), Position(1, 0)],
        [Position(0, 0), Position(0, 1), Position(0, 2), Position(1, 2)],
        [Position(0, 0), Position(0, 1), Position(1, 0), Position(2, 0)],
        [Position(0, 0), Position(0, 1), Position(1, 1), Position(2, 1)],
        [Position(0, 0), Position(1, 0), Position(1, 1), Position(1, 2)],
        [Position(0, 2), Position(1, 0), Position(1, 1), Position(1, 2)],
        // I
        [Position(0, 0), Position(1, 0), Position(2, 0), Position(3, 0)],
        [Position(0, 0), Position(0, 1), Position(0, 2), Position(0, 3)],
        // T
        [Position(0, 0), Position(0, 1), Position(0, 2), Position(1, 1)],
        [Position(0, 1), Position(1, 0), Position(1, 1), Position(2, 1)],
        [Position(0, 1), Position(1, 0), Position(1, 1), Position(1, 2)],
        [Position(0, 0), Position(1, 0), Position(1, 1), Position(2, 0)],
        // S
        [Position(0, 0), Position(0, 1), Position(1, 1), Position(1, 2)],
        [Position(0, 1), Position(0, 2), Position(1, 0), Position(1, 1)],
        [Position(0, 0), Position(1, 0), Position(1, 1), Position(2, 1)],
        [Position(0, 1), Position(1, 0), Position(1, 1), Position(2, 0)],
        // O
        [Position(0, 0), Position(0, 1), Position(1, 0), Position(1, 1)],
    ]
    
    var objArray = [GridDotObject]()
    var pos2hint = [Position: Int]()
    
    init(layout: [String], delegate: FenceLitsGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count + 1, layout[0].length + 1)
        objArray = Array<GridDotObject>(repeating: Array<GridLineObject>(repeating: .empty, count: 4), count: rows * cols)
        
        for r in 0..<rows - 1 {
            let str = layout[r]
            for c in 0..<cols - 1 {
                let ch = str[c]
                guard case "0"..."9" = ch else {continue}
                pos2hint[Position(r, c)] = ch.toInt!
            }
        }
        for r in 0..<rows - 1 {
            self[r, 0][2] = .line
            self[r + 1, 0][0] = .line
            self[r, cols - 1][2] = .line
            self[r + 1, cols - 1][0] = .line
        }
        for c in 0..<cols - 1 {
            self[0, c][1] = .line
            self[0, c + 1][3] = .line
            self[rows - 1, c][1] = .line
            self[rows - 1, c + 1][3] = .line
        }
        
        let state = FenceLitsGameState(game: self)
        levelInitilized(state: state)
    }
    
    subscript(p: Position) -> GridDotObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> GridDotObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
}
