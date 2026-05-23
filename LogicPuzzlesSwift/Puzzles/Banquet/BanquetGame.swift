//
//  BanquetGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class BanquetGame: GridGame<BanquetGameState> {
    static let offset = Position.Directions4
    static let PUZ_UNKNOWN = -1
    static let PUZ_CANCEL_MOVE = -1

    var pos2hint = [Position: Int]()
    var fixedTables = Set<Position>()
    
    init(layout: [String], delegate: BanquetGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let ch = str[c]
                guard ch != " " else {continue}
                let n = ch == "?" ? BanquetGame.PUZ_UNKNOWN : ch.toInt!
                let p = Position(r, c)
                if n == 0 {
                    fixedTables.insert(p)
                } else {
                    pos2hint[p] = n
                }
            }
        }
        
        let state = BanquetGameState(game: self)
        levelInitialized(state: state)
    }
    
}
