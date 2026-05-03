//
//  TheMagicNumberGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class TheMagicNumberGame: GridGame<TheMagicNumberGameState> {
    static let offset = Position.Directions4
    static let chars = " ABC"

    var objArray = [TheMagicNumberObject]()
    var shaded = [Position]()
    var symbolCountPerRowCol = 0

    init(layout: [String], delegate: TheMagicNumberGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        objArray = Array<TheMagicNumberObject>(repeating: .empty, count: rows * cols)
        symbolCountPerRowCol = rows / 3
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let p = Position(r, c)
                let ch = str[c]
                let ch2 = ch.isLowercase ? ch.uppercased : ch
                if ch.isLowercase { shaded.append(p) }
                self[p] = TheMagicNumberObject(rawValue: TheMagicNumberGame.chars.getIndexOf(ch2)!)!
            }
        }

        let state = TheMagicNumberGameState(game: self)
        levelInitialized(state: state)
    }
    
    subscript(p: Position) -> TheMagicNumberObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> TheMagicNumberObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
}
