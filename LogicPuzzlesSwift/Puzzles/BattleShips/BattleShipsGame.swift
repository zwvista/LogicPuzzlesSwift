//
//  BattleShipsGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class BattleShipsGame: GridGame<BattleShipsGameState> {
    static let offset = Position.Directions8

    var row2hint = [Int]()
    var col2hint = [Int]()
    var pos2obj = [Position: BattleShipsObject]()
    
    init(layout: [String], delegate: BattleShipsGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count - 1, layout[0].length - 1)
        row2hint = Array<Int>(repeating: 0, count: rows)
        col2hint = Array<Int>(repeating: 0, count: cols)
        
        for r in 0..<rows + 1 {
            let str = layout[r]
            for c in 0..<cols + 1 {
                let p = Position(r, c)
                let ch = str[c]
                if ch.isNumber {
                    let n = ch.toInt!
                    if r == rows {
                        col2hint[c] = n
                    } else if c == cols {
                        row2hint[r] = n
                    }
                } else {
                    pos2obj[p] = switch ch {
                    case "^": .battleShipTop
                    case "v": .battleShipBottom
                    case "<": .battleShipLeft
                    case ">": .battleShipRight
                    case "+": .battleShipMiddle
                    case "o": .battleShipUnit
                    case ".": .marker
                    default: .empty
                    }
                }
                
            }
        }
        
        let state = BattleShipsGameState(game: self)
        levelInitialized(state: state)
    }
    
}
