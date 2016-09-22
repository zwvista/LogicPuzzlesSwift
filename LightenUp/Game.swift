//
//  Game.swift
//  LightenUp
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

// http://stackoverflow.com/questions/24066304/how-can-i-make-a-weak-protocol-reference-in-pure-swift-w-o-objc
protocol GameDelegate: class {
    func moveAdded(_ game: Game, move: GameMove)
    func levelUpdated(_ game: Game, move: GameMove)
    func gameSolved(_ game: Game)
}

class Game {
    private var stateIndex = 0
    private var states = [GameState]()
    private var state: GameState {return states[stateIndex]}
    private var moves = [GameMove]()
    private var move: GameMove {return moves[stateIndex - 1]}
    
    private(set) var walls = [Position: Int]()
    private(set) weak var delegate: GameDelegate?
    var size: Position {return state.size}
    var isSolved: Bool {return state.isSolved}
    var canUndo: Bool {return stateIndex > 0}
    var canRedo: Bool {return stateIndex < states.count - 1}
    var moveIndex: Int {return stateIndex}
    var moveCount: Int {return states.count - 1}
    
    private func moveAdded(move: GameMove) {
        delegate?.moveAdded(self, move: move)
        levelUpdated(move: move)
    }
    
    private func levelUpdated(move: GameMove) {
        delegate?.levelUpdated(self, move: move)
        if isSolved { delegate?.gameSolved(self) }
    }
    
    init(layout: [String], delegate: GameDelegate? = nil) {
        self.delegate = delegate
        
        var state = GameState(rows: layout.count, cols: layout[0].characters.count)
        
        func addWall(row: Int, col: Int, lightbulbs: Int) {
            state[row, col] = .wall(lightbulbs: lightbulbs)
            walls[Position(row, col)] = lightbulbs
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
        levelUpdated(move: GameMove())
   }
    
    func toggleObject(p: Position) {
        if canRedo {
            states.removeSubrange((stateIndex + 1) ..< states.count)
            moves.removeSubrange(stateIndex ..< moves.count)
        }
        
        // copy a state
        var state = self.state
        let (changed, move) = state.toggleObject(p: p)
        
        guard changed else {return}
        
        states.append(state)
        stateIndex += 1
        moves.append(move)
        moveAdded(move: move)
    }
    
    func undo() {
        guard canUndo else {return}
        var move = self.move
        move.toadd = !move.toadd
        stateIndex -= 1
        levelUpdated(move: move)
    }
    
    func redo() {
        guard canRedo else {return}
        stateIndex += 1
        levelUpdated(move: move)
    }
    
}
