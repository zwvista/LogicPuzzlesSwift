//
//  KropkiGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class KropkiGame: GridGame<KropkiGameViewController> {
    static let offset = [
        Position(-1, 0),
        Position(0, 1),
        Position(1, 0),
        Position(0, -1),
    ]

    var pos2horzHint = [Position: KropkiHint]()
    var pos2vertHint = [Position: KropkiHint]()
    
    init(layout: [String], bordered: Bool, delegate: KropkiGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(bordered ? layout.count / 4 : layout.count / 2 + 1, layout[0].length)
        
        for r in 0..<rows * 2 - 1 {
            let str = layout[r]
            for c in 0..<cols {
                let p = Position(r / 2, c)
                let ch = str[c]
                let kh: KropkiHint = ch == "W" ? .consecutive :
                    ch == "B" ? .twice : .none;
                if r % 2 == 0 {
                    pos2horzHint[p] = kh
                } else {
                    pos2vertHint[p] = kh
                }
            }
        }
                
        let state = KropkiGameState(game: self)
        states.append(state)
        levelInitilized(state: state)
    }
    
    private func changeObject(move: inout KropkiGameMove, f: (inout KropkiGameState, inout KropkiGameMove) -> Bool) -> Bool {
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
    
    func switchObject(move: inout KropkiGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.switchObject(move: &move)})
    }
    
    func setObject(move: inout KropkiGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.setObject(move: &move)})
    }
    
}
