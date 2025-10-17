//
//  ThermometersGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class ThermometersGame: GridGame<ThermometersGameState> {
    static let offset = Position.Directions4
    static let offset2 = Position.Directions8
    static let bulbs = "v<^>"
    static let parts = "URDLurdl|-"

    var row2hint = [Int]()
    var col2hint = [Int]()
    var objArray = [Character]()

    subscript(p: Position) -> Character {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> Character {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }

    init(layout: [String], delegate: ThermometersGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count - 1, layout[0].length - 1)
        row2hint = Array<Int>(repeating: 0, count: rows)
        col2hint = Array<Int>(repeating: 0, count: cols)
        objArray = Array<Character>(repeating: " ", count: cols)
        
        var bulbArray = [Position]()
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
                } else if ThermometersGame.bulbs.contains(ch) {
                    bulbArray.append(p)
                }
            }
        }
        for p in bulbArray {
            let (r, c) = p.destructured
            let ch = layout[r][c]
            let d = ThermometersGame.bulbs.getIndexOf(ch)!
            self[p] = ThermometersGame.parts[d]
            let os = ThermometersGame.offset[(d + 2) % 4]
            var p2 = p + os
            while isValid(p: p2) {
                let ch2 = layout[p2.row][p2.col]
                if ch2 == "+" {
                    self[p2] = d % 2 == 0 ? "|" : "-"
                } else if ch2 == "o" {
                    self[p2] = ThermometersGame.parts[d + 4]
                    break
                }
                p2 += os
            }
        }
        
        let state = ThermometersGameState(game: self)
        levelInitialized(state: state)
    }
    
}
