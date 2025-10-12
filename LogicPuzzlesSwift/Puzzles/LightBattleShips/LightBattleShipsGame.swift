//
//  LightBattleShipsGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class LightBattleShipsGame: GridGame<LightBattleShipsGameState> {
    static let offset = Position.Directions8

    var pos2hint = [Position: Int]()
    var pos2obj = [Position: LightBattleShipsObject]()
    
    init(layout: [String], delegate: LightBattleShipsGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let p = Position(r, c)
                let ch = str[c]
                switch ch {
                case "^":
                    pos2obj[p] = .battleShipTop
                case "v":
                    pos2obj[p] = .battleShipBottom
                case "<":
                    pos2obj[p] = .battleShipLeft
                case ">":
                    pos2obj[p] = .battleShipRight
                case "+":
                    pos2obj[p] = .battleShipMiddle
                case "o":
                    pos2obj[p] = .battleShipUnit
                case ".":
                    pos2obj[p] = .marker
                case "0"..."9":
                    pos2obj[p] = .hint(state: .normal)
                    pos2hint[p] = ch.toInt!
                default:
                    break
                }
            }
        }
        
        let state = LightBattleShipsGameState(game: self)
        levelInitilized(state: state)
    }
    
}
