//
//  CloudsAndClearsGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class CloudsAndClearsGame: GridGame<CloudsAndClearsGameState> {
    static let offset = Position.Directions4
    static let offset2 = [
        Position.North,
        Position.NorthEast,
        Position.East,
        Position.SouthEast,
        Position.South,
        Position.SouthWest,
        Position.West,
        Position.NorthWest,
        Position.Zero,
    ]

    var pos2hint = [Position: Int]()
    
    init(layout: [String], delegate: CloudsAndClearsGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)

        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let ch = str[c]
                let p = Position(r, c)
                if ch != " " { pos2hint[p] = ch.toInt! }
            }
        }

        let state = CloudsAndClearsGameState(game: self)
        levelInitialized(state: state)
    }
    
}
