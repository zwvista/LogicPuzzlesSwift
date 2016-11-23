//
//  BridgesGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class IslandInfo {
    var bridges = 0
    var neighbors: [Position?] = [nil, nil, nil, nil]
}

class BridgesGame: CellsGame<BridgesGameViewController, BridgesGameMove, BridgesGameState>, GameBase {
    static let gameID = "Bridges"
    static let offset = [
        Position(-1, 0),
        Position(0, 1),
        Position(1, 0),
        Position(0, -1),
    ];
    
    var islandsInfo = [Position: IslandInfo]()
    func isIsland(p: Position) -> Bool {return islandsInfo[p] != nil}
    
    init(layout: [String], delegate: BridgesGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let p = Position(r, c)
                let ch = str[c]
                switch ch {
                case "0"..."9":
                    let info = IslandInfo()
                    info.bridges = ch.toInt!
                    islandsInfo[p] = info
                default:
                    break
                }
            }
        }
        for (p, info) in islandsInfo {
            for i in 0..<4 {
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
    
    func switchBridges(move: BridgesGameMove) -> Bool {
        var pFrom = move.pFrom, pTo = move.pTo
        guard let o = islandsInfo[pFrom] else {return false}
        guard let _ = o.neighbors.filter({$0 == pTo}).first else {return false}
        
        if canRedo {
            states.removeSubrange((stateIndex + 1)..<states.count)
            moves.removeSubrange(stateIndex..<moves.count)
        }
        // copy a state
        let state = self.state.copy()
        if pTo < pFrom {swap(&pFrom, &pTo)}
        let move = BridgesGameMove(pFrom: pFrom, pTo: pTo)
        guard state.switchBridges(move: move) else {return false}
        
        states.append(state)
        stateIndex += 1
        moves.append(move)
        moveAdded(move: move)
        levelUpdated(from: states[stateIndex - 1], to: state)
        return true
    }
        
}
