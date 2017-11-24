//
//  NumberLinkGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class NumberLinkGame: GridGame<NumberLinkGameViewController> {
    static let offset = [
        Position(-1, 0),
        Position(0, 1),
        Position(1, 0),
        Position(0, -1),
    ]

    var pos2hint = [Position: Int]()
    var hint2rng = [Int: [Position]]()

    init(layout: [String], delegate: NumberLinkGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let p = Position(r, c)
                func f(n: Int) {
                    pos2hint[p] = n
                    var rng = hint2rng[n] ?? [Position]()
                    rng.append(p)
                    hint2rng[n] = rng
                }
                let ch = str[c]
                switch ch {
                case "0"..."9": f(n: ch.toInt!)
                case "A"..."Z": f(n: Int(ch.asciiValue!) - Int(Character("A").asciiValue!) + 10)
                default: break
                }
            }
        }
        
        let state = NumberLinkGameState(game: self)
        states.append(state)
        levelInitilized(state: state)
    }
    
    private func changeObject(move: inout NumberLinkGameMove, f: (inout NumberLinkGameState, inout NumberLinkGameMove) -> Bool) -> Bool {
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
    
    func setObject(move: inout NumberLinkGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.setObject(move: &move)})
    }
    
}
