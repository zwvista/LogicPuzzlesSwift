//
//  ScissorsGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class ScissorsGame: GridGame<ScissorsGameState> {
    static let offset = Position.Directions4
    static let offset2 = Position.Square2x2Offset
    static let PUZ_BACK_SLASH: Character = "\\"
    static let PUZ_FRONT_SLASH: Character = "/"

    var objArray = [Character]()
    var numbers = [Character]()
    subscript(p: Position) -> Character {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> Character {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }

    init(layout: [String], delegate: ScissorsGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        objArray = Array<Character>(repeating: " ", count: rows * cols)

        var chMax: Character = "1"
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let ch = str[c]
                self[r, c] = ch
                if chMax < ch { chMax = ch }
            }
        }

        let nMax = Int(chMax.asciiValue! - Character("0").asciiValue!)
        numbers = (1...nMax).map { Character("\($0)") }

        let state = ScissorsGameState(game: self)
        levelInitialized(state: state)
    }
    
}
