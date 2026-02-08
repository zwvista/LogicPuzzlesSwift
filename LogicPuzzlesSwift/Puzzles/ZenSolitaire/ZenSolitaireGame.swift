//
//  ZenSolitaireGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class ZenSolitaireGame: GridGame<ZenSolitaireGameState> {
    static let offset = Position.Directions4
    static let PUZ_STONE = -1
    static let PUZ_EMPTY = 0

    var stones = [Position]()

    init(layout: [String], delegate: ZenSolitaireGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                if str[c] != " " {
                    stones.append(Position(r, c))
                }
            }
        }
        
        let state = ZenSolitaireGameState(game: self)
        levelInitialized(state: state)
    }
}
