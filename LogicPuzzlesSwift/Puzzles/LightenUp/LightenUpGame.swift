//
//  LightenUpGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class LightenUpGame: GridGame<LightenUpGameViewController> {
    static let offset = [
        Position(-1, 0),
        Position(0, 1),
        Position(1, 0),
        Position(0, -1),
    ]

    var wall2Lightbulbs = [Position: Int]()
    
    init(layout: [String], delegate: LightenUpGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        
        func addWall(row: Int, col: Int, lightbulbs: Int) {
            wall2Lightbulbs[Position(row, col)] = lightbulbs
        }
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let ch = str[c]
                switch ch {
                case "W":
                    addWall(row: r, col: c, lightbulbs: -1)
                case "0"..."9":
                    addWall(row: r, col: c, lightbulbs: ch.toInt!)
                default:
                    break
                }
            }
        }
        
        let state = LightenUpGameState(game: self)
        levelInitilized(state: state)
    }
    
    func switchObject(move: inout LightenUpGameMove) -> Bool {
        changeObject(move: &move, f: { state, move in state.switchObject(move: &move) })
    }
    
    func setObject(move: inout LightenUpGameMove) -> Bool {
        changeObject(move: &move, f: { state, move in state.setObject(move: &move) })
    }
    
}
