//
//  LightUpGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class LightUpGame: CellsGame<LightUpGameMove, LightUpGameState> {
    static let offset = [
        Position(-1, 0),
        Position(0, 1),
        Position(1, 0),
        Position(0, -1),
    ];

    var wall2Lightbulbs = [Position: Int]()
    
    init(layout: [String], delegate: LightUpGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].characters.count)
        var state = LightUpGameState(game: self)
        
        func addWall(row: Int, col: Int, lightbulbs: Int) {
            wall2Lightbulbs[Position(row, col)] = lightbulbs
            state[row, col].objType = .wall(state: lightbulbs <= 0 ? .complete : .normal)
        }
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let ch = str[str.index(str.startIndex, offsetBy: c)]
                switch ch {
                case "W":
                    addWall(row: r, col: c, lightbulbs: -1)
                case "0"..."9":
                    addWall(row: r, col: c, lightbulbs: Int(String(ch))!)
                default:
                    break
                }
            }
        }
        
        states.append(state)
        levelInitilized(state: state)
    }
    
    private func changeObject(move: inout LightUpGameMove, f: (inout LightUpGameState, inout LightUpGameMove) -> Bool) -> Bool {
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
    
    func switchObject(move: inout LightUpGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.switchObject(move: &move)})
    }
    
    func setObject(move: inout LightUpGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.setObject(move: &move)})
    }
    
}
