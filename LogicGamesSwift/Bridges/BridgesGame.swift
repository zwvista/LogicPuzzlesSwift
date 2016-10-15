//
//  BridgesGame.swift
//  LogicGamesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

// http://stackoverflow.com/questions/24066304/how-can-i-make-a-weak-protocol-reference-in-pure-swift-w-o-objc
protocol BridgesGameDelegate: class {
    func moveAdded(_ game: BridgesGame, move: BridgesGameMove)
    func levelInitilized(_ game: BridgesGame, state: BridgesGameState)
    func levelUpdated(_ game: BridgesGame, from stateFrom: BridgesGameState, to stateTo: BridgesGameState)
    func gameSolved(_ game: BridgesGame)
}

class IslandInfo {
    var bridges = 0
    var neighbors = [Position]()
}

class BridgesGame {
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
        return row >= 0 && col >= 0 && row < rows && col < cols
    }
    var islandsInfo = [Position: IslandInfo]()
    func isIsland(p: Position) -> Bool {
        return islandsInfo[p] != nil
     }
    
    private var stateIndex = 0
    private var states = [BridgesGameState]()
    private var state: BridgesGameState {return states[stateIndex]}
    private var moves = [BridgesGameMove]()
    private var move: BridgesGameMove {return moves[stateIndex - 1]}
    
    private(set) weak var delegate: BridgesGameDelegate?
    var isSolved: Bool {return state.isSolved}
    var canUndo: Bool {return stateIndex > 0}
    var canRedo: Bool {return stateIndex < states.count - 1}
    var moveIndex: Int {return stateIndex}
    var moveCount: Int {return states.count - 1}
    
    private func moveAdded(move: BridgesGameMove) {
        delegate?.moveAdded(self, move: move)
    }
    
    private func levelInitilized(state: BridgesGameState) {
        delegate?.levelInitilized(self, state: state)
        if isSolved { delegate?.gameSolved(self) }
    }
    
    private func levelUpdated(from stateFrom: BridgesGameState, to stateTo: BridgesGameState) {
        delegate?.levelUpdated(self, from: stateFrom, to: stateTo)
        if isSolved { delegate?.gameSolved(self) }
    }
    
    init(layout: [String], delegate: BridgesGameDelegate? = nil) {
        self.delegate = delegate
        
        size = Position(layout.count, layout[0].characters.count)
        for r in 0 ..< rows {
            let str = layout[r]
            for c in 0 ..< cols {
                let p = Position(r, c)
                let ch = str[str.index(str.startIndex, offsetBy: c)]
                switch ch {
                case "0" ... "9":
                    let info = IslandInfo()
                    info.bridges = Int(String(ch))!
                    islandsInfo[p] = info
                default:
                    break
                }
            }
        }
        for (p, info) in islandsInfo {
            for i in 0 ..< 4 {
                let os = BridgesGame.offset[i]
                var p2 = p + os
                while(isValid(p: p2)) {
                    if let _ = islandsInfo[p2] {
                        info.neighbors[i] = p2
                        break
                    }
                    p2 += os
                }
            }
        }
        
        let state = BridgesGameState(game: self)
        states.append(state)
        levelInitilized(state: state)
    }
    
    private func switchBridges(p1: Position, p2: Position) -> Bool {
        guard let o = islandsInfo[p1] else {return false}
        guard o.neighbors.contains(p2) else {return false}
        
        if canRedo {
            states.removeSubrange((stateIndex + 1) ..< states.count)
            moves.removeSubrange(stateIndex ..< moves.count)
        }
        // copy a state
        var state = self.state
        let move = BridgesGameMove(p1: p1, p2: p2)
        guard state.switchBridges(move: move) else {return false}
        
        states.append(state)
        stateIndex += 1
        moves.append(move)
        moveAdded(move: move)
        levelUpdated(from: states[stateIndex - 1], to: state)
        return true
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
