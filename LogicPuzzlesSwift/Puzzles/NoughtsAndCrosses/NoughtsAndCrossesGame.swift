//
//  NoughtsAndCrossesGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class NoughtsAndCrossesGame: GridGame<NoughtsAndCrossesGameViewController> {
    static let offset = [
        Position(-1, 0),
        Position(0, 1),
        Position(1, 0),
        Position(0, -1),
    ]

    var objArray = [Character]()
    var chMax: Character
    var noughts = Set<Position>()

    init(layout: [String], chMax: Character, delegate: NoughtsAndCrossesGameViewController? = nil) {
        self.chMax = chMax
        
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        objArray = Array<Character>(repeating: " ", count: rows * cols)

        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let p = Position(r, c)
                let ch = str[c]
                if ch == "O" {noughts.insert(p)}
                self[r, c] = ch == "O" ? " " : ch
            }
        }

        let state = NoughtsAndCrossesGameState(game: self)
        states.append(state)
        levelInitilized(state: state)
    }
    
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

    func switchObject(move: inout NoughtsAndCrossesGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.switchObject(move: &move)})
    }
    
    func setObject(move: inout NoughtsAndCrossesGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.setObject(move: &move)})
    }
    
}
