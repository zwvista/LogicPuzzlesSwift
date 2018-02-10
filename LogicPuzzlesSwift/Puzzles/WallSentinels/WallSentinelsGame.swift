//
//  WallSentinelsGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class WallSentinelsGame: GridGame<WallSentinelsGameViewController> {
    static let offset = [
        Position(-1, 0),
        Position(0, 1),
        Position(1, 0),
        Position(0, -1),
    ]
    static let offset2 = [
        Position(0, 0),
        Position(0, 1),
        Position(1, 0),
        Position(1, 1),
    ]

    var objArray = [WallSentinelsObject]()

    init(layout: [String], delegate: WallSentinelsGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length / 2)
        objArray = Array<WallSentinelsObject>(repeating: .empty, count: rows * cols)

        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let s = str[c * 2...c * 2 + 1]
                guard s != "  " else {continue}
                let n = s[1].toInt!
                self[r, c] = s[0] == "." ? .hintLand(tiles: n, state: .normal) : .hintWall(tiles: n, state: .normal)
            }
        }
        
        let state = WallSentinelsGameState(game: self)
        states.append(state)
        levelInitilized(state: state)
    }
    
    subscript(p: Position) -> WallSentinelsObject {
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> WallSentinelsObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }

    private func changeObject(move: inout WallSentinelsGameMove, f: (inout WallSentinelsGameState, inout WallSentinelsGameMove) -> Bool) -> Bool {
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
    
    func switchObject(move: inout WallSentinelsGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.switchObject(move: &move)})
    }
    
    func setObject(move: inout WallSentinelsGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.setObject(move: &move)})
    }
    
}
