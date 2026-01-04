//
//  IslandConnectionsGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class IslandConnectionsGame: GridGame<IslandConnectionsGameState> {
    static let offset = Position.Directions4
    
    var islandsInfo = [Position: IslandInfo]()
    func isIsland(p: Position) -> Bool { islandsInfo[p] != nil }
    
    init(layout: [String], delegate: IslandConnectionsGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let ch = str[c]
                guard case "0"..."9" = ch else {continue}
                let info = IslandInfo()
                info.bridges = ch.toInt!
                islandsInfo[Position(r, c)] = info
            }
        }
        for (p, info) in islandsInfo {
            for i in 0..<4 {
                let os = IslandConnectionsGame.offset[i]
                var p2 = p + os
                while isValid(p: p2) {
                    if let _ = islandsInfo[p2] {
                        info.neighbors[i] = p2
                        break
                    }
                    p2 += os
                }
            }
        }
        
        let state = IslandConnectionsGameState(game: self)
        levelInitialized(state: state)
    }
    
    func switchIslandConnections(move: inout IslandConnectionsGameMove) -> Bool {
        var pFrom = move.pFrom, pTo = move.pTo
        guard let o = islandsInfo[pFrom], let _ = o.neighbors.filter({ $0 == pTo }).first else { return false }
        return changeObject(move: &move) { state, move in
            if pTo < pFrom { swap(&pFrom, &pTo) }
            let move = IslandConnectionsGameMove(pFrom: pFrom, pTo: pTo)
            return state.switchIslandConnections(move: move)
        }
    }

    override func setObject(move: inout IslandConnectionsGameMove) -> Bool {
        switchIslandConnections(move: &move)
    }
}
