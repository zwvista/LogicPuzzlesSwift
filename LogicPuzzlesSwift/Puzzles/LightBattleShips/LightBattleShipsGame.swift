//
//  LightBattleShipsGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class LightBattleShipsGame: GridGame<LightBattleShipsGameState> {
    static let offset = Position.Directions4
    static let offset2 = Position.Directions8

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
                if ch.isNumber {
                    pos2obj[p] = .hint
                    pos2hint[p] = ch.toInt!
                } else {
                    pos2obj[p] = switch ch {
                    case "^": .battleShipTop
                    case "v": .battleShipBottom
                    case "<": .battleShipLeft
                    case ">": .battleShipRight
                    case "+": .battleShipMiddle
                    case "o": .battleShipUnit
                    case ".": .marker
                    default: nil
                    }
                }
            }
        }
        
        let state = LightBattleShipsGameState(game: self)
        levelInitialized(state: state)
    }
    
}
