//
//  HitoriGame.swift
//  LogicGamesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

// http://stackoverflow.com/questions/24066304/how-can-i-make-a-weak-protocol-reference-in-pure-swift-w-o-objc
protocol HitoriGameDelegate: class {
    func moveAdded(_ game: HitoriGame, move: HitoriGameMove)
    func levelInitilized(_ game: HitoriGame, state: HitoriGameState)
    func levelUpdated(_ game: HitoriGame, from stateFrom: HitoriGameState, to stateTo: HitoriGameState)
    func gameSolved(_ game: HitoriGame)
}

class HitoriGame {
    static let offset = [
        Position(-1, 0),
        Position(0, 1),
        Position(1, 0),
        Position(0, -1),
    ];

    var size: Position
    var rows: Int { return size.row }
    var cols: Int { return size.col }    
    func isValid(p: Position) -> Bool {
        return isValid(row: p.row, col: p.col)
    }
    func isValid(row: Int, col: Int) -> Bool {
        //return row >= 0 && col >= 0 && row < rows && col < cols
        return 0 ..< rows ~= row && 0 ..< cols ~= col
    }
    var objArray = [Character]()
    subscript(p: Position) -> Character {
        get {
            return objArray[p.row * cols + p.col]
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
    
    private var stateIndex = 0
    private var states = [HitoriGameState]()
    private var state: HitoriGameState {return states[stateIndex]}
    private var moves = [HitoriGameMove]()
    private var move: HitoriGameMove {return moves[stateIndex - 1]}
    
    private(set) weak var delegate: HitoriGameDelegate?
    var isSolved: Bool {return state.isSolved}
    var canUndo: Bool {return stateIndex > 0}
    var canRedo: Bool {return stateIndex < states.count - 1}
    var moveIndex: Int {return stateIndex}
    var moveCount: Int {return states.count - 1}
    
    private func moveAdded(move: HitoriGameMove) {
        delegate?.moveAdded(self, move: move)
    }
    
    private func levelInitilized(state: HitoriGameState) {
        delegate?.levelInitilized(self, state: state)
        if isSolved { delegate?.gameSolved(self) }
    }
    
    private func levelUpdated(from stateFrom: HitoriGameState, to stateTo: HitoriGameState) {
        delegate?.levelUpdated(self, from: stateFrom, to: stateTo)
        if isSolved { delegate?.gameSolved(self) }
    }
    
    init(layout: [String], delegate: HitoriGameDelegate? = nil) {
        self.delegate = delegate
        
        size = Position(layout.count, layout[0].characters.count)
        objArray = Array<Character>(repeating: " ", count: rows * cols)
        
        let state = HitoriGameState(game: self)
        
        for r in 0 ..< rows {
            let str = layout[r]
            for c in 0 ..< cols {
                let ch = str[str.index(str.startIndex, offsetBy: c)]
                self[r, c] = ch
            }
        }
        
        states.append(state)
        levelInitilized(state: state)
    }
    
    private func changeObject(move: inout HitoriGameMove, f: (inout HitoriGameState, inout HitoriGameMove) -> Bool) -> Bool {
        if canRedo {
            states.removeSubrange((stateIndex + 1) ..< states.count)
            moves.removeSubrange(stateIndex ..< moves.count)
        }
        // copy a state
        var state = self.state
        guard f(&state, &move) else {return false}
        
        states.append(state)
        stateIndex += 1
        moves.append(move)
        moveAdded(move: move)
        levelUpdated(from: states[stateIndex - 1], to: state)
        return true
    }
    
    func switchObject(move: inout HitoriGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.switchObject(move: &move)})
    }
    
    func setObject(move: inout HitoriGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.setObject(move: &move)})
    }
    
    func undo() {
        guard canUndo else {return}
        stateIndex -= 1
        levelUpdated(from: states[stateIndex + 1], to: state)
    }
    
    func redo() {
        guard canRedo else {return}
        stateIndex += 1
        levelUpdated(from: states[stateIndex - 1], to: state)
    }
    
}
