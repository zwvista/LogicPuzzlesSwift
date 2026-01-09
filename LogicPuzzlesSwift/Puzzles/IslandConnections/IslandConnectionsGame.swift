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
    static let PUZ_UNKNOWN = -1

    var islandsInfo = [Position: IslandConnectionsIslandInfo]()
    var shaded = Set<Position>()
    func isIsland(p: Position) -> Bool { islandsInfo[p] != nil }
    func isShaded(p: Position) -> Bool { shaded.contains(p) }
    
    init(layout: [String], delegate: IslandConnectionsGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count * 2 - 1, layout[0].length * 2 - 1)
        
        for r in stride(from: 0, to: rows, by: 2) {
            let str = layout[r / 2]
            for c in stride(from: 0, to: cols, by: 2) {
                let ch = str[c / 2]
                let p = Position(r, c)
                switch ch {
                case "S":
                    shaded.insert(p)
                case "O":
                    islandsInfo[p] = IslandConnectionsIslandInfo(b: IslandConnectionsGame.PUZ_UNKNOWN)
                case " ":
                    break
                default:
                    islandsInfo[p] = IslandConnectionsIslandInfo(b: ch.toInt!)
                }
            }
        }
        for (p, info) in islandsInfo {
            for i in 0..<4 {
                let os = IslandConnectionsGame.offset[i]
                var p2 = p + os
                while isValid(p: p2) && !isShaded(p: p2) {
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
