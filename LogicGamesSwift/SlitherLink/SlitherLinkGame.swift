//
//  SlitherLinkGame.swift
//  LogicGamesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

// http://stackoverflow.com/questions/24066304/how-can-i-make-a-weak-protocol-reference-in-pure-swift-w-o-objc
protocol SlitherLinkGameDelegate: class {
    func moveAdded(_ game: SlitherLinkGame, move: SlitherLinkGameMove)
    func levelInitilized(_ game: SlitherLinkGame, state: SlitherLinkGameState)
    func levelUpdated(_ game: SlitherLinkGame, from stateFrom: SlitherLinkGameState, to stateTo: SlitherLinkGameState)
    func gameSolved(_ game: SlitherLinkGame)
}

class SlitherLinkGame {
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
    var wall2Lightbulbs = [Position: Int]()
    
    private var stateIndex = 0
    private var states = [SlitherLinkGameState]()
    private var state: SlitherLinkGameState {return states[stateIndex]}
    private var moves = [SlitherLinkGameMove]()
    private var move: SlitherLinkGameMove {return moves[stateIndex - 1]}
    
    private(set) weak var delegate: SlitherLinkGameDelegate?
    var isSolved: Bool {return state.isSolved}
    var canUndo: Bool {return stateIndex > 0}
    var canRedo: Bool {return stateIndex < states.count - 1}
    var moveIndex: Int {return stateIndex}
    var moveCount: Int {return states.count - 1}
    
    private func moveAdded(move: SlitherLinkGameMove) {
        delegate?.moveAdded(self, move: move)
    }
    
    private func levelInitilized(state: SlitherLinkGameState) {
        delegate?.levelInitilized(self, state: state)
        if isSolved { delegate?.gameSolved(self) }
    }
    
    private func levelUpdated(from stateFrom: SlitherLinkGameState, to stateTo: SlitherLinkGameState) {
        delegate?.levelUpdated(self, from: stateFrom, to: stateTo)
        if isSolved { delegate?.gameSolved(self) }
    }
    
    init(layout: [String], delegate: SlitherLinkGameDelegate? = nil) {
        self.delegate = delegate
        
        size = Position(layout.count, layout[0].characters.count)
        var state = SlitherLinkGameState(game: self)
        
        func addWall(row: Int, col: Int, lightbulbs: Int) {
            wall2Lightbulbs[Position(row, col)] = lightbulbs
            state[row, col].objType = .wall(state: lightbulbs <= 0 ? .complete : .normal)
        }
        
        for r in 0 ..< rows {
            let str = layout[r]
            for c in 0 ..< cols {
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
    
    private func changeObject(move: inout SlitherLinkGameMove, f: (inout SlitherLinkGameState, inout SlitherLinkGameMove) -> Bool) -> Bool {
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
    
    func switchObject(move: inout SlitherLinkGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.switchObject(move: &move)})
    }
    
    func setObject(move: inout SlitherLinkGameMove) -> Bool {
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
