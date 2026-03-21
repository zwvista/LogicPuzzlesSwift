//
//  LightenUpGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class LightenUpGame: GridGame<LightenUpGameState> {
    static let offset = Position.Directions4

    var pos2hint = [Position: Int]()
    
    init(layout: [String], delegate: LightenUpGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)

        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let ch = str[c]
                let p = Position(r, c)
                if ch == "W" {
                    pos2hint[p] = -1
                } else if ch.isNumber {
                    pos2hint[p] = ch.toInt!
                }
            }
        }
        
        let state = LightenUpGameState(game: self)
        levelInitialized(state: state)
    }
    
}
