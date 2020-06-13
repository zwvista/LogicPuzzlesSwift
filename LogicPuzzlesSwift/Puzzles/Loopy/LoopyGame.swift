//
//  LoopyGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class LoopyGame: GridGame<LoopyGameViewController> {
    static let offset = [
        Position(-1, 0),
        Position(0, 1),
        Position(1, 0),
        Position(0, -1),
    ]

    var objArray = [GridDotObject]()
    
    init(layout: [String], delegate: LoopyGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count / 2 + 1, layout[0].length / 2 + 1)
        objArray = Array<GridDotObject>(repeating: Array<GridLineObject>(repeating: .empty, count: 4), count: rows * cols)
        
        for r in 0..<rows {
            var str = layout[2 * r]
            for c in 0..<cols - 1 {
                let ch = str[2 * c + 1]
                if ch == "-" {
                    self[r, c][1] = .line
                    self[r, c + 1][3] = .line
                }
            }
            guard r < rows - 1 else {break}
            str = layout[2 * r + 1]
            for c in 0..<cols {
                let ch = str[2 * c]
                if ch == "|" {
                    self[r, c][2] = .line
                    self[r + 1, c][0] = .line
                }
            }
        }
        
        let state = LoopyGameState(game: self)
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
    
    func switchObject(move: inout LoopyGameMove) -> Bool {
        changeObject(move: &move, f: {state, move in state.switchObject(move: &move)})
    }
    
    func setObject(move: inout LoopyGameMove) -> Bool {
        changeObject(move: &move, f: {state, move in state.setObject(move: &move)})
    }
    
}
