//
//  CastleBaileyGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class CastleBaileyGame: GridGame<CastleBaileyGameViewController> {
    static let offset = [
        Position(-1, 0),
        Position(0, 1),
        Position(1, 0),
        Position(0, -1),
    ]
    static let offset2 = [
        Position(-1, -1),
        Position(-1, 0),
        Position(0, 0),
        Position(0, -1),
    ]

    var pos2hint = [Position: Int]()
    
    init(layout: [String], delegate: CastleBaileyGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count - 1, layout[0].length - 1)

        for r in 0..<rows + 1 {
            let str = layout[r]
            for c in 0..<cols + 1 {
                let ch = str[c]
                let p = Position(r, c)
                if ch != " " { pos2hint[p] = ch.toInt! }
            }
        }

        let state = CastleBaileyGameState(game: self)
        levelInitilized(state: state)
    }
        
    func switchObject(move: inout CastleBaileyGameMove) -> Bool {
        changeObject(move: &move, f: { state, move in state.switchObject(move: &move) })
    }
    
    func setObject(move: inout CastleBaileyGameMove) -> Bool {
        changeObject(move: &move, f: { state, move in state.setObject(move: &move) })
    }
    
}
