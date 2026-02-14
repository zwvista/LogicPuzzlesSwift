//
//  CloudsAndClearsGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class CloudsAndClearsGame: GridGame<CloudsAndClearsGameState> {
    static let offset = Position.Directions4
    static let offset2 = [
        Position(-1, -1),
        Position(-1, 0),
        Position(0, 0),
        Position(0, -1),
    ]
    static let car_offset = [
        [Position(0, 0), Position(0, 1)],
        [Position(0, 0), Position(0, 1), Position(0, 2)],
        [Position(0, 0), Position(1, 0)],
        [Position(0, 0), Position(1, 0), Position(2, 0)],
    ]
    static let car_objects: [[CloudsAndClearsObject]] = [
        [.left, .right],
        [.left, .horizontal, .right],
        [.top, .bottom],
        [.top, .vertical, .bottom],
    ]

    var pos2hint = [Position: Int]()
    
    init(layout: [String], delegate: CloudsAndClearsGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)

        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let ch = str[c]
                let p = Position(r, c)
                if ch != " " { pos2hint[p] = ch.toInt! }
            }
        }

        let state = CloudsAndClearsGameState(game: self)
        levelInitialized(state: state)
    }
    
}
