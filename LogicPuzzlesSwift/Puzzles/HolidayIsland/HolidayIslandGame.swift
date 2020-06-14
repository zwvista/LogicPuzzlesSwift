//
//  HolidayIslandGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class HolidayIslandGame: GridGame<HolidayIslandGameState> {
    static let offset = [
        Position(-1, 0),
        Position(0, 1),
        Position(1, 0),
        Position(0, -1),
    ]

    var pos2hint = [Position: Int]()

    init(layout: [String], delegate: HolidayIslandGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let p = Position(r, c)
                let ch = str[c]
                if ch != " " { pos2hint[p] = ch.toInt! }
            }
        }

        let state = HolidayIslandGameState(game: self)
        levelInitilized(state: state)
    }
    
}
