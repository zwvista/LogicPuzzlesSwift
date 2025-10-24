//
//  PlanksGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class PlanksGame: GridGame<PlanksGameState> {
    static let offset = Position.Directions4
    static let offset2 = [
        Position(0, 0),
        Position(1, 1),
        Position(1, 1),
        Position(0, 0),
    ]
    static let dirs = [1, 0, 3, 2]

    var planks = Set<Position>()
    
    init(layout: [String], delegate: PlanksGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count + 1, layout[0].length + 1)
        
        for r in 0..<rows - 1 {
            let str = layout[r]
            for c in 0..<cols - 1 {
                let ch = str[c]
                guard ch != " " else {continue}
                planks.insert(Position(r, c))
            }
        }
        
        let state = PlanksGameState(game: self)
        levelInitialized(state: state)
    }
    
}
