//
//  OnlyStraightsGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class OnlyStraightsGame: GridGame<OnlyStraightsGameState> {
    static let offset = Position.Directions4

    var objArray = [OnlyStraightsTown]()
    subscript(p: Position) -> OnlyStraightsTown {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> OnlyStraightsTown {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    init(layout: [String], delegate: OnlyStraightsGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        objArray = Array<OnlyStraightsTown>(repeating: .empty, count: rows * cols)
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let ch = str[c]
                self[r, c] = switch str[c] {
                case "1": .center
                case "2": .right
                case "4": .bottom
                case "3": .centerRight
                case "5": .centerBottom
                case "6": .rightBottom
                case "7": .centerRightBottom
                default: .empty
                }
            }
        }
        let state = OnlyStraightsGameState(game: self)
        levelInitialized(state: state)
    }
}
