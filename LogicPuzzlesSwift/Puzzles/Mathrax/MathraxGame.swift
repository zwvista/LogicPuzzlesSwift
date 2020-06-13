//
//  MathraxGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class MathraxGame: GridGame<MathraxGameViewController> {
    static let offset = [
        Position(-1, 0),
        Position(0, 1),
        Position(1, 0),
        Position(0, -1),
    ]
    static let offset2 = [
        Position(0, 0),
        Position(1, 1),
        Position(1, 0),
        Position(0, 1),
    ]

    var objArray = [Int]()
    var pos2hint = [Position: MathraxHint]()
    
    init(layout: [String], delegate: MathraxGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count / 2 + 1, layout[0].length)
        objArray = Array<Int>(repeating: 0, count: rows * cols)

        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let ch = str[c]
                let n = ch == " " ? 0 : ch.toInt!
                self[r, c] = n
            }
        }
        for r in 0..<rows - 1 {
            let str = layout[rows + r]
            for c in 0..<cols - 1 {
                let (s, ch) = (str[c * 3...c * 3 + 1], str[c * 3 + 2])
                guard ch != " " else {continue}
                pos2hint[Position(r, c)] = MathraxHint(op: ch, result: s == "  " ? 0 : s.toInt()!)
            }
        }

        let state = MathraxGameState(game: self)
        states.append(state)
        levelInitilized(state: state)
    }
    
    subscript(p: Position) -> Int {
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> Int {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func switchObject(move: inout MathraxGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.switchObject(move: &move)})
    }
    
    func setObject(move: inout MathraxGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.setObject(move: &move)})
    }
    
}
