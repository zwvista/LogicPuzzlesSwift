//
//  LineSweeperGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class LineSweeperGame: GridGame<LineSweeperGameViewController> {
    static let offset = [
        Position(-1, 0),
        Position(-1, 1),
        Position(0, 1),
        Position(1, 1),
        Position(1, 0),
        Position(1, -1),
        Position(0, -1),
        Position(-1, -1),
    ]

    var pos2hint = [Position: Int]()
    func isHint(p: Position) -> Bool {return pos2hint[p] != nil}
    
    init(layout: [String], delegate: LineSweeperGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let ch = str[c]
                guard case "0"..."9" = ch else {continue}
                pos2hint[Position(r, c)] = ch.toInt!
            }
        }
        
        let state = LineSweeperGameState(game: self)
        levelInitilized(state: state)
    }
    
    func setObject(move: inout LineSweeperGameMove) -> Bool {
        changeObject(move: &move, f: {state, move in state.setObject(move: &move)})
    }
    
}
