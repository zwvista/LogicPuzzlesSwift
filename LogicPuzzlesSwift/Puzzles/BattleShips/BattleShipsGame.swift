//
//  BattleShipsGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class BattleShipsGame: GridGame<BattleShipsGameViewController> {
    static let offset = [
        Position(-1, 0),
        Position(0, 1),
        Position(1, 0),
        Position(0, -1),
    ]

    var row2hint = [Int]()
    var col2hint = [Int]()
    var pos2cloud = [Position]()
    
    init(layout: [String], delegate: BattleShipsGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count - 1, layout[0].length - 1)
        row2hint = Array<Int>(repeating: 0, count: rows)
        col2hint = Array<Int>(repeating: 0, count: cols)
        
        for r in 0..<rows + 1 {
            let str = layout[r]
            for c in 0..<cols + 1 {
                let p = Position(r, c)
                let ch = str[c]
                switch ch {
                case "C":
                    pos2cloud.append(p)
                case "0"..."9":
                    let n = ch.toInt!
                    if r == rows {
                        col2hint[c] = n
                    } else if c == cols {
                        row2hint[r] = n
                    }
                default:
                    break
                }
            }
        }
        
        let state = BattleShipsGameState(game: self)
        states.append(state)
        levelInitilized(state: state)
    }
    
    private func changeObject(move: inout BattleShipsGameMove, f: (inout BattleShipsGameState, inout BattleShipsGameMove) -> Bool) -> Bool {
        if canRedo {
            states.removeSubrange((stateIndex + 1)..<states.count)
            moves.removeSubrange(stateIndex..<moves.count)
        }
        // copy a state
        var state = self.state.copy()
        guard f(&state, &move) else {return false}
        
        states.append(state)
        stateIndex += 1
        moves.append(move)
        moveAdded(move: move)
        levelUpdated(from: states[stateIndex - 1], to: state)
        return true
    }
    
    func switchObject(move: inout BattleShipsGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.switchObject(move: &move)})
    }
    
    func setObject(move: inout BattleShipsGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.setObject(move: &move)})
    }
    
}
