//
//  KropkiGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class KropkiGame: GridGame<KropkiGameViewController> {
    static let offset = [
        Position(-1, 0),
        Position(0, 1),
        Position(1, 0),
        Position(0, -1),
    ]

    var objArray = [KropkiHint]()
    subscript(p: Position) -> KropkiHint {
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> KropkiHint {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    init(layout: [String], delegate: KropkiGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count / 2 + 1, layout[0].length)
        objArray = Array<KropkiHint>(repeating: .none, count: (rows * 2 - 1) * cols)
        
        for r in 0..<rows * 2 - 1 {
            let str = layout[r]
            for c in 0..<cols {
                let ch = str[c]
                self[r, c] = ch == "W" ? .consecutive :
                    ch == "B" ? .twice : .none;
            }
        }
                
        let state = KropkiGameState(game: self)
        states.append(state)
        levelInitilized(state: state)
    }
    
    private func changeObject(move: inout KropkiGameMove, f: (inout KropkiGameState, inout KropkiGameMove) -> Bool) -> Bool {
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
    
    func switchObject(move: inout KropkiGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.switchObject(move: &move)})
    }
    
    func setObject(move: inout KropkiGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.setObject(move: &move)})
    }
    
}
