//
//  BotanicalParkGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class BotanicalParkGame: GridGame<BotanicalParkGameState> {
    static let offset = Position.Directions4
    static let offset2 = Position.Directions8

    var pos2arrow = [Position: Int]()
    let onlyOneArrow: Bool
    
    init(layout: [String], onlyOneArrow: Bool, delegate: BotanicalParkGameViewController? = nil) {
        self.onlyOneArrow = onlyOneArrow
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let p = Position(r, c)
                let ch = str[c]
                if ch == " " {continue}
                let n = ch.toInt!
                pos2arrow[p] = n
            }
        }
        
        let state = BotanicalParkGameState(game: self)
        levelInitialized(state: state)
    }
    
}
