//
//  SheepAndWolvesGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class SheepAndWolvesGame: GridGame<SheepAndWolvesGameState> {
    static let offset = Position.Directions4
    static let offset2 = [
        Position(0, 0),
        Position(1, 1),
        Position(1, 1),
        Position(0, 0),
    ]
    static let dirs = [1, 0, 3, 2]

    var pos2hint = [Position: Int]()
    var sheep = [Position]()
    var wolves = [Position]()
    
    init(layout: [String], delegate: SheepAndWolvesGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count + 1, layout[0].length + 1)
        
        for r in 0..<rows - 1 {
            let str = layout[r]
            for c in 0..<cols - 1 {
                let ch = str[c]
                let p = Position(r, c)
                switch ch {
                case "0"..."9":
                    pos2hint[p] = ch.toInt!
                case "S":
                    sheep.append(p)
                case "W":
                    wolves.append(p)
                default:
                    break
                }
            }
        }
        
        let state = SheepAndWolvesGameState(game: self)
        levelInitialized(state: state)
    }
    
}
