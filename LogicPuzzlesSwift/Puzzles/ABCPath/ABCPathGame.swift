//
//  ABCPathGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class ABCPathGame: GridGame<ABCPathGameViewController> {
    static let offset = [
        Position(-1, 0),
        Position(-1, 1),
        Position(0, 1),
        Position(1, 1),
        Position(1, 0),
        Position(1, -1),
        Position(0, -1),
        Position(-1, -1),
    ]

    override func isValid(row: Int, col: Int) -> Bool {
        return 1..<rows - 1 ~= row && 1..<cols - 1 ~= col
    }

    var objArray = [Character]()
    var ch2pos = [Character: Position]()
    subscript(p: Position) -> Character {
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> Character {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    init(layout: [String], delegate: ABCPathGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        objArray = Array<Character>(repeating: " ", count: rows * cols)
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let p = Position(r, c)
                let ch = str[c]
                self[p] = ch
                if r == 0 || r == rows - 1 || c == 0 || c == cols - 1 {
                    ch2pos[ch] = p
                }
            }
        }
        
        let state = ABCPathGameState(game: self)
        levelInitilized(state: state)
    }
    
    func switchObject(move: inout ABCPathGameMove) -> Bool {
        changeObject(move: &move, f: {state, move in state.switchObject(move: &move)})
    }
    
    func setObject(move: inout ABCPathGameMove) -> Bool {
        changeObject(move: &move, f: {state, move in state.setObject(move: &move)})
    }
    
}
