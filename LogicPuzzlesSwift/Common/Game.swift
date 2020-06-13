//
//  Game.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

// http://stackoverflow.com/questions/24066304/how-can-i-make-a-weak-protocol-reference-in-pure-swift-w-o-objc
protocol GameDelegate: class {
    associatedtype GM
    associatedtype GS: GameStateBase
    func moveAdded(_ game: AnyObject, move: GM)
    func levelInitilized(_ game: AnyObject, state: GS)
    func levelUpdated(_ game: AnyObject, from stateFrom: GS, to stateTo: GS)
    func gameSolved(_ game: AnyObject)
}

protocol GameBase: class {
    var moveIndex: Int {get}
    var isSolved: Bool {get}
    var moveCount: Int {get}
    func undo()
    func redo()
}

class Game<GD: GameDelegate>: GameBase {
    typealias GM = GD.GM
    typealias GS = GD.GS
    var stateIndex = 0
    var states = [GS]()
    var currentState: GS {return states[stateIndex]}
    var moves = [GM]()
    
    var isSolved: Bool {currentState.isSolved}
    var canUndo: Bool {stateIndex > 0}
    var canRedo: Bool {stateIndex < states.count - 1}
    var moveIndex: Int {stateIndex}
    var moveCount: Int {states.count - 1}
    
    weak var delegate: GD?
    
    init(delegate: GD? = nil) {
        self.delegate = delegate
    }
    
    func moveAdded(move: GM) {
        delegate?.moveAdded(self, move: move)
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
        var state = currentState.copy() as! GD.GS
        guard f(&state, &move) else {return false}
        
        states.append(state)
        stateIndex += 1
        moves.append(move)
        moveAdded(move: move)
        levelUpdated(from: states[stateIndex - 1], to: state)
        return true
    }

    deinit {
        print("deinit called: \(NSStringFromClass(type(of: self)))")
    }
}

protocol GridGameBase: GameBase {
    var size: Position! {get}
    func isValid(p: Position) -> Bool
    func isValid(row: Int, col: Int) -> Bool
}

class GridGame<GD: GameDelegate>: Game<GD>, GridGameBase {
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
