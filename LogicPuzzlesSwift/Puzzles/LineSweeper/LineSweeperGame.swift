//
//  LineSweeperGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

// http://stackoverflow.com/questions/24066304/how-can-i-make-a-weak-protocol-reference-in-pure-swift-w-o-objc
protocol LineSweeperGameDelegate: class {
    func moveAdded(_ game: LineSweeperGame, move: LineSweeperGameMove)
    func levelInitilized(_ game: LineSweeperGame, state: LineSweeperGameState)
    func levelUpdated(_ game: LineSweeperGame, from stateFrom: LineSweeperGameState, to stateTo: LineSweeperGameState)
    func gameSolved(_ game: LineSweeperGame)
}

class LineSweeperGame: CellsGame<LineSweeperGameViewController, LineSweeperGameMove, LineSweeperGameState> {
    static let offset = [
        Position(-1, 0),
        Position(0, 1),
        Position(1, 0),
        Position(0, -1),
    ];

    var pos2hint = [Position: Int]()
    
    init(layout: [String], delegate: LineSweeperGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count + 1, layout[0].length + 1)
        
        for r in 0..<rows - 1 {
            let str = layout[r]
            for c in 0..<cols - 1 {
                let p = Position(r, c)
                let ch = str[c]
                switch ch {
                case "0"..."9":
                    let n = Int(String(ch))!
                    pos2hint[p] = n
                default:
                    break
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
    
    func switchObject(move: inout LineSweeperGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.switchObject(move: &move)})
    }
    
    func setObject(move: inout LineSweeperGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.setObject(move: &move)})
    }
    
}
