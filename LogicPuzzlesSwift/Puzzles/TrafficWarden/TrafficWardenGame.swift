//
//  TrafficWardenGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class TrafficWardenGame: GridGame<TrafficWardenGameState> {
    static let offset = Position.Directions4
    static let PUZ_GREEN: Character = "G"
    static let PUZ_RED: Character = "R"
    static let PUZ_YELLOW: Character = "Y"

    var pos2hint = [Position: TrafficWardenHint]()

    init(layout: [String], delegate: TrafficWardenGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length / 2)
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let (ch1, ch2) = (str[c * 2], str[c * 2 + 1])
                guard ch1 != " " else {continue}
                let n = ch2.isNumber ? ch2.toInt! : Int(ch2.asciiValue!) - Int(Character("A").asciiValue!) + 10
                pos2hint[Position(r, c)] = TrafficWardenHint(light: ch1, len: n)
            }
        }
        let state = TrafficWardenGameState(game: self)
        levelInitialized(state: state)
    }
}
