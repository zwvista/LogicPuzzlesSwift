//
//  Game.swift
//  LightUpSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

// http://stackoverflow.com/questions/24066304/how-can-i-make-a-weak-protocol-reference-in-pure-swift-w-o-objc
protocol GameDelegate: class {
    func moveAdded(_ game: Game, move: GameMove)
    func levelInitilized(_ game: Game, state: GameState)
    func levelUpdated(_ game: Game, from stateFrom: GameState, to stateTo: GameState)
    func gameSolved(_ game: Game)
}

class Game {
    private var stateIndex = 0
    private var states = [GameState]()
    private var state: GameState {return states[stateIndex]}
    private var moves = [GameMove]()
    private var move: GameMove {return moves[stateIndex - 1]}
    
    private(set) weak var delegate: GameDelegate?
    var size: Position {return state.size}
    var isSolved: Bool {return state.isSolved}
    var canUndo: Bool {return stateIndex > 0}
    var canRedo: Bool {return stateIndex < states.count - 1}
    var moveIndex: Int {return stateIndex}
    var moveCount: Int {return states.count - 1}
    
    private func moveAdded(move: GameMove) {
        delegate?.moveAdded(self, move: move)
    }
    
    private func levelInitilized(state: GameState) {
        delegate?.levelInitilized(self, state: state)
        if isSolved { delegate?.gameSolved(self) }
    }
    
    private func levelUpdated(from stateFrom: GameState, to stateTo: GameState) {
        delegate?.levelUpdated(self, from: stateFrom, to: stateTo)
        if isSolved { delegate?.gameSolved(self) }
    }
    
    init(layout: [String], delegate: GameDelegate? = nil) {
        self.delegate = delegate
        
        var state = GameState(rows: layout.count, cols: layout[0].characters.count)
        
        func addWall(row: Int, col: Int, lightbulbs: Int) {
            state[row, col].objType = .wall(lightbulbs: lightbulbs, state: lightbulbs <= 0 ? .complete : .normal)
        }
        
        for r in 0 ..< state.size.row {
            let str = layout[r]
            for c in 0 ..< state.size.col {
                let ch = str[str.index(str.startIndex, offsetBy: c)]
                switch ch {
                case "W":
                    addWall(row: r, col: c, lightbulbs: -1)
                case "0" ... "9":
                    addWall(row: r, col: c, lightbulbs: Int(String(ch))!)
                default:
                    break
                }
            }
        }
        
        states.append(state)
        levelInitilized(state: state)
    }
    
    private func changeObject(p: Position, f: (inout GameState) -> (Bool, GameMove)) -> Bool {
        if canRedo {
            states.removeSubrange((stateIndex + 1) ..< states.count)
            moves.removeSubrange(stateIndex ..< moves.count)
        }
        // copy a state
        var state = self.state
        let (changed, move) = f(&state)
        if changed {
            states.append(state)
            stateIndex += 1
            moves.append(move)
            moveAdded(move: move)
            levelUpdated(from: states[stateIndex - 1], to: state)
        }
        return changed
    }
    
    func switchObject(p: Position) -> Bool {
        return changeObject(p: p, f: {state in state.switchObject(p: p)})
    }
    
    func setObject(p: Position, objType: GameObjectType) -> Bool {
        return changeObject(p: p, f: {state in state.setObject(p: p, objType: objType)})
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
