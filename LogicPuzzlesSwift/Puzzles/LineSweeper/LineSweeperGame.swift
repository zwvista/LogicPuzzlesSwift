//
//  LineSweeperGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class LineSweeperGame: CellsGame<LineSweeperGameViewController, LineSweeperGameMove, LineSweeperGameState>, GameBase {
    static let gameID = "LineSweeper"
    static let offset = [
        Position(-1, 0),
        Position(-1, 1),
        Position(0, 1),
        Position(1, 1),
        Position(1, 0),
        Position(1, -1),
        Position(0, -1),
        Position(-1, -1),
    ];

    var pos2hint = [Position: Int]()
    func isHint(p: Position) -> Bool {return pos2hint[p] != nil}
    
    init(layout: [String], delegate: LineSweeperGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let p = Position(r, c)
                let ch = str[c]
                if "0"..."9" ~= ch {
                    pos2hint[p] = ch.toInt!
                }
            }
        }
        
        let state = LineSweeperGameState(game: self)
        states.append(state)
        levelInitilized(state: state)
    }
    
    private func changeObject(move: inout LineSweeperGameMove, f: (inout LineSweeperGameState, inout LineSweeperGameMove) -> Bool) -> Bool {
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
    
    func setObject(move: inout LineSweeperGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.setObject(move: &move)})
    }
    
}
