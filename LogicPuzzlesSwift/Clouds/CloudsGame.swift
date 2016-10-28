//
//  CloudsGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

// http://stackoverflow.com/questions/24066304/how-can-i-make-a-weak-protocol-reference-in-pure-swift-w-o-objc
protocol CloudsGameDelegate: class {
    func moveAdded(_ game: CloudsGame, move: CloudsGameMove)
    func levelInitilized(_ game: CloudsGame, state: CloudsGameState)
    func levelUpdated(_ game: CloudsGame, from stateFrom: CloudsGameState, to stateTo: CloudsGameState)
    func gameSolved(_ game: CloudsGame)
}

class CloudsGame {
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
    var row2hint = [Int]()
    var col2hint = [Int]()
    var pos2cloud = [Position]()
    
    private var stateIndex = 0
    private var states = [CloudsGameState]()
    private var state: CloudsGameState {return states[stateIndex]}
    private var moves = [CloudsGameMove]()
    private var move: CloudsGameMove {return moves[stateIndex - 1]}
    
    private(set) weak var delegate: CloudsGameDelegate?
    var isSolved: Bool {return state.isSolved}
    var canUndo: Bool {return stateIndex > 0}
    var canRedo: Bool {return stateIndex < states.count - 1}
    var moveIndex: Int {return stateIndex}
    var moveCount: Int {return states.count - 1}
    
    private func moveAdded(move: CloudsGameMove) {
        delegate?.moveAdded(self, move: move)
    }
    
    private func levelInitilized(state: CloudsGameState) {
        delegate?.levelInitilized(self, state: state)
        if isSolved { delegate?.gameSolved(self) }
    }
    
    private func levelUpdated(from stateFrom: CloudsGameState, to stateTo: CloudsGameState) {
        delegate?.levelUpdated(self, from: stateFrom, to: stateTo)
        if isSolved { delegate?.gameSolved(self) }
    }
    
    init(layout: [String], delegate: CloudsGameDelegate? = nil) {
        self.delegate = delegate
        
        size = Position(layout.count - 1, layout[0].characters.count - 1)
        row2hint = Array<Int>(repeating: 0, count: rows)
        col2hint = Array<Int>(repeating: 0, count: cols)
        
        var state = CloudsGameState(game: self)
        state.row2state = Array<CloudsHintState>(repeating: .normal, count: rows)
        state.col2state = Array<CloudsHintState>(repeating: .normal, count: cols)
        
        for r in 0 ..< rows + 1 {
            let str = layout[r]
            for c in 0 ..< cols + 1 {
                let p = Position(r, c)
                let ch = str[str.index(str.startIndex, offsetBy: c)]
                switch ch {
                case "C":
                    pos2cloud.append(p)
                case "0" ... "9":
                    let n = Int(String(ch))!
                    if r == rows {
                        col2hint[c] = n
                        state.col2state[c] = n == 0 ? .complete : .normal
                    } else if c == cols {
                        row2hint[r] = n
                        state.row2state[r] = n == 0 ? .complete : .normal
                    }
                default:
                    break
                }
            }
        }
        
        states.append(state)
        levelInitilized(state: state)
    }
    
    private func changeObject(move: inout CloudsGameMove, f: (inout CloudsGameState, inout CloudsGameMove) -> Bool) -> Bool {
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
    
    func switchObject(move: inout CloudsGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.switchObject(move: &move)})
    }
    
    func setObject(move: inout CloudsGameMove) -> Bool {
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
