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

class Game<GD: GameDelegate, GM, GS: GameStateBase> where GD.GM == GM, GD.GS == GS {
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
    
    weak var delegate: GD?
    
    init(delegate: GD? = nil) {
        self.delegate = delegate
    }
    
    func moveAdded(move: GM) {
        delegate?.moveAdded(self, move: move)
    }
    
    func levelInitilized(state: GS) {
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
        levelUpdated(from: states[stateIndex + 1], to: state)
    }
    
    func redo() {
        guard canRedo else {return}
        stateIndex += 1
        levelUpdated(from: states[stateIndex - 1], to: state)
    }
    
    deinit {
        print("deinit called")
    }
}

protocol CellsGameBase: class {
    var size: Position! {get}
    func isValid(p: Position) -> Bool;
    func isValid(row: Int, col: Int) -> Bool;
}

class CellsGame<GD: GameDelegate, GM, GS: GameStateBase>: Game<GD, GM, GS>, CellsGameBase where GD.GM == GM, GD.GS == GS {
    var size: Position!
    var rows: Int { return size.row }
    var cols: Int { return size.col }
    func isValid(p: Position) -> Bool {
        return isValid(row: p.row, col: p.col)
    }
    func isValid(row: Int, col: Int) -> Bool {
        return (0..<rows ~= row) && (0..<cols ~= col)
    }
    
    override init(delegate: GD? = nil) {
        super.init(delegate: delegate)
    }
}
