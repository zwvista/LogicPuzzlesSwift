//
//  CastlePatrolGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class CastlePatrolGame: GridGame<CastlePatrolGameState> {
    static let offset = Position.Directions4

    var wall2Lightbulbs = [Position: Int]()
    
    init(layout: [String], delegate: CastlePatrolGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        
        func addWall(row: Int, col: Int, lightbulbs: Int) {
            wall2Lightbulbs[Position(row, col)] = lightbulbs
        }
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let ch = str[c]
                switch ch {
                case "W":
                    addWall(row: r, col: c, lightbulbs: -1)
                case "0"..."9":
                    addWall(row: r, col: c, lightbulbs: ch.toInt!)
                default:
                    break
                }
            }
        }
        
        let state = CastlePatrolGameState(game: self)
        levelInitialized(state: state)
    }
    
}
