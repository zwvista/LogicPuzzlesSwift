//
//  HiddenCloudsGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class HiddenCloudsGame: GridGame<HiddenCloudsGameState> {
    static let offset = Position.Directions4
    static let offset2 = [
        Position.North,
        Position.East,
        Position.South,
        Position.West,
        Position.Zero,
    ]

    var pos2hint = [Position: Int]()
    
    init(layout: [String], delegate: HiddenCloudsGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let p = Position(r, c)
                let ch = str[c]
                if ch.isNumber {
                    pos2hint[p] = ch.toInt!
                }
            }
        }
        
        let state = HiddenCloudsGameState(game: self)
        levelInitialized(state: state)
    }
    
}
