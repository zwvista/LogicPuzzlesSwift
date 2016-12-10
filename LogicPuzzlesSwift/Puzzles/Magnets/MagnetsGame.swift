//
//  MagnetsGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class MagnetsGame: CellsGame<MagnetsGameViewController, MagnetsGameMove, MagnetsGameState>, GameBase {
    static let gameID = "Magnets"
    static let offset = [
        Position(-1, 0),
        Position(0, 1),
        Position(1, 0),
        Position(0, -1),
    ];

    var row2hint = [Int]()
    var col2hint = [Int]()
    var areas = [MagnetsArea]()
    
    init(layout: [String], delegate: MagnetsGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count - 2, layout[0].length - 2)
        row2hint = Array<Int>(repeating: 0, count: rows * 2)
        col2hint = Array<Int>(repeating: 0, count: cols * 2)
        
        for r in 0..<rows + 2 {
            let str = layout[r]
            for c in 0..<cols + 2 {
                let p = Position(r, c)
                let ch = str[c]
                switch ch {
                case "0"..."9":
                    let n = ch.toInt!
                    if r >= rows {
                        col2hint[2 * c + r - rows] = n
                    } else if c >= cols {
                        row2hint[2 * r + c - cols] = n
                    }
                case ".":
                    areas.append(MagnetsArea(p: p, type: .single))
                case "H":
                    areas.append(MagnetsArea(p: p, type: .horizontal))
                case "V":
                    areas.append(MagnetsArea(p: p, type: .vertical))
                default:
                    break
                }
            }
        }
        
        let state = MagnetsGameState(game: self)
        states.append(state)
        levelInitilized(state: state)
    }
    
    private func changeObject(move: inout MagnetsGameMove, f: (inout MagnetsGameState, inout MagnetsGameMove) -> Bool) -> Bool {
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
    
    func switchObject(move: inout MagnetsGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.switchObject(move: &move)})
    }
    
    func setObject(move: inout MagnetsGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.setObject(move: &move)})
    }
    
}
