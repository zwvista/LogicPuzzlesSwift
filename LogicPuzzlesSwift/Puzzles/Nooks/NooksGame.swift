//
//  NooksGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class NooksGame: GridGame<NooksGameState> {
    static let offset = Position.Directions4
    static let offset2 = Position.Square2x2Offset
    static let PUZ_UNKNOWN = -1

    var pos2hint = [Position: Int]()
    
    init(layout: [String], delegate: NooksGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let ch = str[c]
                guard ch != " " else {continue}
                pos2hint[Position(r, c)] = ch == "?" ? NooksGame.PUZ_UNKNOWN : ch.toInt!
            }
        }
        
        let state = NooksGameState(game: self)
        levelInitialized(state: state)
    }
    
}
