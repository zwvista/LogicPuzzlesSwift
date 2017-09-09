//
//  PowerGridGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class PowerGridGame: GridGame<PowerGridGameViewController> {
    static let offset = [
        Position(-1, 0),
        Position(0, 1),
        Position(1, 0),
        Position(0, -1),
    ]

    var row2hint = [Int]()
    var col2hint = [Int]()
    var pos2post = [Position]()
    
    init(layout: [String], elemLevel: XMLElement, delegate: PowerGridGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count - 1, layout[0].length - 1)
        row2hint = Array<Int>(repeating: 0, count: rows)
        col2hint = Array<Int>(repeating: 0, count: cols)
        
        for r in 0..<rows + 1 {
            let str = layout[r]
            for c in 0..<cols + 1 {
                let ch = str[c]
                guard case "0"..."9" = ch else {continue}
                let n = ch.toInt!
                if r == rows {
                    col2hint[c] = n
                } else if c == cols {
                    row2hint[r] = n
                }
            }
        }
        
        let state = PowerGridGameState(game: self)
        states.append(state)
        levelInitilized(state: state)
    }
    
    private func changeObject(move: inout PowerGridGameMove, f: (inout PowerGridGameState, inout PowerGridGameMove) -> Bool) -> Bool {
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
    
    func switchObject(move: inout PowerGridGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.switchObject(move: &move)})
    }
    
    func setObject(move: inout PowerGridGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.setObject(move: &move)})
    }
    
}
