//
//  LoopyGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class LoopyGame: CellsGame<LoopyGameViewController, LoopyGameMove, LoopyGameState>, GameBase {
    static var gameID = "Loopy"
    static let offset = [
        Position(-1, 0),
        Position(0, 1),
        Position(1, 0),
        Position(0, -1),
    ];

    var objArray = [LoopyObject]()
    
    init(layout: [String], delegate: LoopyGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count / 2 + 1, layout[0].length / 2 + 1)
        objArray = Array<LoopyObject>(repeating: Array<Bool>(repeating: false, count: 4), count: rows * cols)
        
        for r in 0..<rows {
            var str = layout[2 * r]
            for c in 0..<cols - 1 {
                let ch = str[2 * c + 1]
                if ch == "-" {self[r, c][1] = true}
            }
            guard r < rows - 1 else {break}
            str = layout[2 * r + 1]
            for c in 0..<cols {
                let ch = str[2 * c]
                if ch == "|" {self[r, c][2] = true}
            }
        }
        
        let state = LoopyGameState(game: self)
        states.append(state)
        levelInitilized(state: state)
    }
    
    subscript(p: Position) -> LoopyObject {
        get {
            return objArray[p.row * cols + p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> LoopyObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    private func changeObject(move: inout LoopyGameMove, f: (inout LoopyGameState, inout LoopyGameMove) -> Bool) -> Bool {
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
    
    func setObject(move: inout LoopyGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.setObject(move: &move)})
    }
    
}
