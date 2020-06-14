//
//  ParkLakesGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class ParkLakesGame: GridGame<ParkLakesGameViewController> {
    static let offset = [
        Position(-1, 0),
        Position(0, 1),
        Position(1, 0),
        Position(0, -1),
    ]

    var pos2hint = [Position: Int]()

    init(layout: [String], delegate: ParkLakesGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length / 2)
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let p = Position(r, c)
                let s = str[c * 2...c * 2 + 1]
                if s != "  " {
                    pos2hint[p] = s == " ?" ? -1 : s.toInt()!
                }
            }
        }

        let state = ParkLakesGameState(game: self)
        levelInitilized(state: state)
    }
    
}
