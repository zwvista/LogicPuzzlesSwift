//
//  TrebuchetGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class TrebuchetGame: GridGame<TrebuchetGameState> {
    static let offset = Position.Directions4

    var pos2hint = [Position: Int]()
    var pos2targets = [Position: [Position]]()
    
    init(layout: [String], delegate: TrebuchetGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let p = Position(r, c)
                let ch = str[c]
                switch ch {
                case "0"..."9": pos2hint[p] = ch.toInt!
                case "A"..."Z": pos2hint[p] = Int(ch.asciiValue!) - Int(Character("A").asciiValue!) + 10
                default: break
                }
            }
        }
        for (p, hint) in pos2hint {
            pos2targets[p] = TrebuchetGame.offset.map { os in
                var p2 = p
                for _ in 0..<hint { p2 += os }
                return p2
            }.filter { isValid(p: $0) }
        }
        
        let state = TrebuchetGameState(game: self)
        levelInitialized(state: state)
    }
    
}
