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

class Game<GM, GS: GameStateBase> {
    var stateIndex = 0
    var states = [GS]()
    var state: GS {return states[stateIndex]}
    var moves = [GM]()
    var move: GM {return moves[stateIndex - 1]}
    
    var isSolved: Bool {return state.isSolved}
    var canUndo: Bool {return stateIndex > 0}
    var canRedo: Bool {return stateIndex < states.count - 1}
    var moveIndex: Int {return stateIndex}
    var moveCount: Int {return states.count - 1}
    
    private let _moveAdded: ((AnyObject, GM) -> Void)?
    private let _levelInitilized: ((AnyObject, GS) -> Void)?
    private let _levelUpdated: ((AnyObject, GS, GS) -> Void)?
    private let _gameSolved: ((AnyObject) -> Void)?
    
    // https://www.natashatherobot.com/swift-type-erasure/
    init<GD: GameDelegate>(delegate: GD? = nil) where GD.GM == GM, GD.GS == GS {
        _moveAdded = delegate?.moveAdded
        _levelInitilized = delegate?.levelInitilized
        _levelUpdated = delegate?.levelUpdated
        _gameSolved = delegate?.gameSolved
    }
    
    func moveAdded(move: GM) {
        _moveAdded?(self, move)
    }
    
    func levelInitilized(state: GS) {
        _levelInitilized?(self, state)
        if isSolved { _gameSolved?(self) }
    }
    
    func levelUpdated(from stateFrom: GS, to stateTo: GS) {
        _levelUpdated?(self, stateFrom, stateTo)
        if isSolved { _gameSolved?(self) }
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

protocol CellsGameBase: class {
    var size: Position! {get}
    func isValid(p: Position) -> Bool;
    func isValid(row: Int, col: Int) -> Bool;
}

class CellsGame<GM, GS: GameStateBase>: Game<GM, GS>, CellsGameBase {
    var size: Position!
    var rows: Int { return size.row }
    var cols: Int { return size.col }
    func isValid(p: Position) -> Bool {
        return isValid(row: p.row, col: p.col)
    }
    func isValid(row: Int, col: Int) -> Bool {
        return row >= 0 && col >= 0 && row < rows && col < cols
    }
    
    override init<GD: GameDelegate>(delegate: GD? = nil) where GD.GM == GM, GD.GS == GS {
        super.init(delegate: delegate)
    }
}
