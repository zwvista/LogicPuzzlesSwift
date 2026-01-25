//
//  PairakabeGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class PairakabeGame: GridGame<PairakabeGameState> {
    static let offset = Position.Directions4
    static let offset2 = [
        Position(0, 0),
        Position(0, 1),
        Position(1, 0),
        Position(1, 1),
    ]

    var pos2hint = [Position: Int]()
    
    init(layout: [String], delegate: PairakabeGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let ch = str[c]
                guard ch.isNumber else {continue}
                pos2hint[Position(r, c)] = ch.toInt!
            }
        }
        
        let state = PairakabeGameState(game: self)
        levelInitialized(state: state)
    }
    
}
