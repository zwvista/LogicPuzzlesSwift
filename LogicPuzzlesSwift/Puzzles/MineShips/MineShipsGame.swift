//
//  MineShipsGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class MineShipsGame: GridGame<MineShipsGameViewController> {
    static let offset = [
        Position(-1, 0),
        Position(-1, 1),
        Position(0, 1),
        Position(1, 1),
        Position(1, 0),
        Position(1, -1),
        Position(0, -1),
        Position(-1, -1),
    ]
    static let offset2 = [
        Position(-1, 1),
        Position(1, 1),
        Position(1, -1),
        Position(-1, -1),
    ]

    var pos2hint = [Position: Int]()
    
    init(layout: [String], elemLevel: XMLElement, delegate: MineShipsGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let ch = str[c]
                guard case "0"..."9" = ch else {continue}
                pos2hint[Position(r, c)] = ch.toInt!
            }
        }
        
        let state = MineShipsGameState(game: self)
        states.append(state)
        levelInitilized(state: state)
    }
    
    private func changeObject(move: inout MineShipsGameMove, f: (inout MineShipsGameState, inout MineShipsGameMove) -> Bool) -> Bool {
        if canRedo {
            states.removeSubrange((stateIndex + 1)..<states.count)
            moves.removeSubrange(stateIndex..<moves.count)
        }
        // copy a state
        var state = self.state.copy()
        guard f(&state, &move) else {return false}
        
        states.append(state)
        stateIndex += 1
        moves.append(move)
        moveAdded(move: move)
        levelUpdated(from: states[stateIndex - 1], to: state)
        return true
    }
    
    func switchObject(move: inout MineShipsGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.switchObject(move: &move)})
    }
    
    func setObject(move: inout MineShipsGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.setObject(move: &move)})
    }
    
}
