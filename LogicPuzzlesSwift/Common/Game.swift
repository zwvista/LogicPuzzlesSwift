//
//  BridgesGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

// http://stackoverflow.com/questions/24066304/how-can-i-make-a-weak-protocol-reference-in-pure-swift-w-o-objc
protocol GameDelegate: class {
    associatedtype G
    associatedtype GM
    associatedtype GS: GameState
    func moveAdded(_ game: G, move: GM)
    func levelInitilized(_ game: G, state: GS)
    func levelUpdated(_ game: G, from stateFrom: GS, to stateTo: GS)
    func gameSolved(_ game: G)
}

class Game<G, GD: GameDelegate, GM, GS: GameState>
    where GD.G == G, GD.GM == GM, GD.GS == GS {
    
    private var stateIndex = 0
    private var states = [GS]()
    private var state: GS {return states[stateIndex]}
    private var moves = [GM]()
    private var move: GM {return moves[stateIndex - 1]}
    
    private(set) weak var delegate: GD?
    var isSolved: Bool {return state.isSolved}
    var canUndo: Bool {return stateIndex > 0}
    var canRedo: Bool {return stateIndex < states.count - 1}
    var moveIndex: Int {return stateIndex}
    var moveCount: Int {return states.count - 1}
    
    func moveAdded(move: GM) {
        delegate?.moveAdded(self as! G, move: move)
    }
    
    func levelInitilized(state: GS) {
        delegate?.levelInitilized(self as! G, state: state)
        if isSolved { delegate?.gameSolved(self as! G) }
    }
    
    func levelUpdated(from stateFrom: GS, to stateTo: GS) {
        delegate?.levelUpdated(self as! G, from: stateFrom, to: stateTo)
        if isSolved { delegate?.gameSolved(self as! G) }
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

class CellsGame<G, GD: GameDelegate, GM, GS: GameState>: Game<G, GD, GM, GS>
    where GD.G == G, GD.GM == GM, GD.GS == GS {
    
    var size: Position!
    var rows: Int { return size.row }
    var cols: Int { return size.col }
    func isValid(p: Position) -> Bool {
        return isValid(row: p.row, col: p.col)
    }
    func isValid(row: Int, col: Int) -> Bool {
        return row >= 0 && col >= 0 && row < rows && col < cols
    }
}
