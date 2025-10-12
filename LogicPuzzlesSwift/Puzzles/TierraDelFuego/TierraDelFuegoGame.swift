//
//  TierraDelFuegoGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class TierraDelFuegoGame: GridGame<TierraDelFuegoGameState> {
    static let offset = Position.Directions4

    var pos2hint = [Position: Character]()

    init(layout: [String], delegate: TierraDelFuegoGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let p = Position(r, c)
                let ch = str[c]
                if ch != " " { pos2hint[p] = ch }
            }
        }

        let state = TierraDelFuegoGameState(game: self)
        levelInitilized(state: state)
    }
    
}
