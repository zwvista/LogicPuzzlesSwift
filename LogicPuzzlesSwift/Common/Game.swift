//
//  Game.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol GameBase: class {
    var moveIndex: Int { get }
    var isSolved: Bool { get }
    var moveCount: Int { get }
    func undo()
    func redo()
}

class Game<GS: GameStateBase>: GameBase {
    typealias GM = GS.GM
    var stateIndex = 0
    var states = [GS]()
    var currentState: GS { states[stateIndex] }
    var moves = [GM]()
    
    var isSolved: Bool { currentState.isSolved }
    var canUndo: Bool { stateIndex > 0 }
    var canRedo: Bool { stateIndex < states.count - 1 }
    var moveIndex: Int { stateIndex }
    var moveCount: Int { states.count - 1 }
    
    weak var delegate: GameGameViewController?
    
    init(delegate: GameGameViewController? = nil) {
        self.delegate = delegate
    }
    
    func levelInitilized(state: GS) {
        states.append(state)
        delegate?.levelInitilized(self, state: state)
        if isSolved { delegate?.gameSolved(self) }
    }
    
    func levelUpdated(from stateFrom: GS, to stateTo: GS) {
        delegate?.levelUpdated(self, from: stateFrom, to: stateTo)
        if isSolved { delegate?.gameSolved(self) }
    }
    
    func undo() {
        guard canUndo else {return}
        stateIndex -= 1
        levelUpdated(from: states[stateIndex + 1], to: currentState)
    }
    
    func redo() {
        guard canRedo else {return}
        stateIndex += 1
        levelUpdated(from: states[stateIndex - 1], to: currentState)
    }
    
    func changeObject(move: inout GM, f: (inout GS, inout GM) -> Bool) -> Bool {
        if canRedo {
            states.removeSubrange((stateIndex + 1)..<states.count)
            moves.removeSubrange(stateIndex..<moves.count)
        }
        // copy a state
        var state = currentState.copy() as! GS
        guard f(&state, &move) else { return false }
        
        states.append(state)
        stateIndex += 1
        moves.append(move)
        delegate?.moveAdded(self, move: move)
        levelUpdated(from: states[stateIndex - 1], to: state)
        return true
    }
    
    func switchObject(move: inout GM) -> Bool {
        changeObject(move: &move, f: { state, move in state.switchObject(move: &move) })
    }
    
    func setObject(move: inout GM) -> Bool {
        changeObject(move: &move, f: { state, move in state.setObject(move: &move) })
    }

    deinit {
        print("deinit called: \(NSStringFromClass(type(of: self)))")
    }
}

protocol GridGameBase: GameBase {
    var size: Position! { get }
    func isValid(p: Position) -> Bool
    func isValid(row: Int, col: Int) -> Bool
}

class GridGame<GS: GameStateBase>: Game<GS>, GridGameBase {
    var size: Position!
    var rows: Int { size.row }
    var cols: Int { size.col }
    func isValid(p: Position) -> Bool {
        isValid(row: p.row, col: p.col)
    }
    func isValid(row: Int, col: Int) -> Bool {
        0..<rows ~= row && 0..<cols ~= col
    }
}
