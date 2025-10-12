//
//  BranchesGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class BranchesGame: GridGame<BranchesGameState> {
    static let offset = Position.Directions4

    var pos2hint = [Position: Int]()
    
    init(layout: [String], delegate: BranchesGameViewController? = nil) {
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

        let state = BranchesGameState(game: self)
        levelInitilized(state: state)
    }
    
}
