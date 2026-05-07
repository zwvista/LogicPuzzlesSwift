//
//  CrossroadBlocksGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class CrossroadBlocksGame: GridGame<CrossroadBlocksGameState> {
    static let offset = Position.Directions4
    static let chars = "^>v<"
    static let PUZ_UNKNOWN = -1

    var pos2hint = [Position: CrossroadBlocksHint]()
    
    init(layout: [String], delegate: CrossroadBlocksGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length / 3)
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let s = str[c * 3...c * 3 + 2]
                guard s[0] != " " else {continue}
                let isBlack = s[0] == "B"
                let num = s[1] == " " ? CrossroadBlocksGame.PUZ_UNKNOWN : s[1].toInt!
                let dir = s[2] == " " ? CrossroadBlocksGame.PUZ_UNKNOWN : CrossroadBlocksGame.chars.getIndexOf(s[2])!
                pos2hint[Position(r, c)] = CrossroadBlocksHint(isBlack: isBlack, num: num, dir: dir)
            }
        }
        let state = CrossroadBlocksGameState(game: self)
        levelInitialized(state: state)
    }
}
