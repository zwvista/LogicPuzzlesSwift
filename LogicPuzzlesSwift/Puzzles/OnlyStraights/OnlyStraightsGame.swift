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
    static let PUZ_TOWN: Character = "O"

    var objArray = [Character]()
    subscript(p: Position) -> Character {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> Character {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    init(layout: [String], delegate: OnlyStraightsGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count * 2 - 1, layout[0].length * 2 - 1)
        objArray = Array<Character>(repeating: " ", count: rows * cols)
        
        for r in stride(from: 0, to: rows, by: 2) {
            let str = layout[r / 2]
            for c in stride(from: 0, to: cols, by: 2) {
                let ch = str[c / 2]
                guard ch.isNumber else {continue}
                let n = ch.toInt!
                if n & 1 != 0 { self[r, c] = OnlyStraightsGame.PUZ_TOWN }
                if n & 2 != 0 { self[r, c + 1] = OnlyStraightsGame.PUZ_TOWN }
                if n & 4 != 0 { self[r + 1, c] = OnlyStraightsGame.PUZ_TOWN }
            }
        }
        let state = OnlyStraightsGameState(game: self)
        levelInitialized(state: state)
    }
}
