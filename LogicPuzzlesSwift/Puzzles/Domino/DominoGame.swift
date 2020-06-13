//
//  DominoGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class DominoGame: GridGame<DominoGameViewController> {
    static let offset = [
        Position(-1, 0),
        Position(0, 1),
        Position(1, 0),
        Position(0, -1),
    ]
    static let offset2 = [
        Position(0, 0),
        Position(1, 1),
        Position(1, 1),
        Position(0, 0),
    ]
    static let dirs = [1, 0, 3, 2]

    var objArray = [GridDotObject]()
    var pos2hint = [Position: Int]()
    
    init(layout: [String], delegate: DominoGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count + 1, layout[0].length + 1)
        objArray = Array<GridDotObject>(repeating: Array<GridLineObject>(repeating: .empty, count: 4), count: rows * cols)
        
        for r in 0..<rows - 1 {
            let str = layout[r]
            for c in 0..<cols - 1 {
                let p = Position(r, c)
                pos2hint[p] = str[c].toInt!
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
        
        let state = DominoGameState(game: self)
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
    
    func switchObject(move: inout DominoGameMove) -> Bool {
        changeObject(move: &move, f: { state, move in state.switchObject(move: &move) })
    }
    
    func setObject(move: inout DominoGameMove) -> Bool {
        changeObject(move: &move, f: { state, move in state.setObject(move: &move) })
    }
    
}
