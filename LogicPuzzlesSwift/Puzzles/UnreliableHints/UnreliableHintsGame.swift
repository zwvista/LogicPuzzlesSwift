//
//  UnreliableHintsGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class UnreliableHintsGame: GridGame<UnreliableHintsGameState> {
    static let offset = Position.Directions4
    static let chars = "^>v<"

    var pos2hint = [Position: UnreliableHintsHint]()

    init(layout: [String], delegate: UnreliableHintsGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length / 2)
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let s = str[c * 2...c * 2 + 1].trimmed()
                guard !s.isEmpty else {continue}
                let num = s[0].toInt!
                let dir = YalooniqGame.chars.getIndexOf(s[1])!
                pos2hint[Position(r, c)] = UnreliableHintsHint(num: num, dir: dir)
            }
        }
                
        let state = UnreliableHintsGameState(game: self)
        levelInitialized(state: state)
    }
    
}
