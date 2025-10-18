//
//  ZenLandscaperGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class ZenLandscaperGame: GridGame<ZenLandscaperGameState> {
    static let offset = Position.Directions4
    static let offset2 = Position.Directions8
    static let bulbs = "^>v<"
    static let parts = "URDLurdl|-"

    var row2hint = [Int]()
    var col2hint = [Int]()
    var objArray = [Character]()
    var thermometers = [[Position]]()

    subscript(p: Position) -> Character {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> Character {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }

    init(layout: [String], delegate: ZenLandscaperGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count - 1, layout[0].length - 1)
        row2hint = Array(repeating: 0, count: rows)
        col2hint = Array(repeating: 0, count: cols)
        objArray = Array(repeating: " ", count: rows * cols)
        
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
                } else if ZenLandscaperGame.bulbs.contains(ch) {
                    thermometers.append(Array(repeating: p, count: 1))
                }
            }
        }
        for i in thermometers.indices {
            let p = thermometers[i][0]
            let ch = layout[p.row][p.col]
            let d = ZenLandscaperGame.bulbs.getIndexOf(ch)!
            self[p] = ZenLandscaperGame.parts[d]
            let d2 = (d + 2) % 4
            let os = ZenLandscaperGame.offset[d2]
            var p2 = p + os
            while isValid(p: p2) {
                thermometers[i].append(p2)
                let ch2 = layout[p2.row][p2.col]
                if ch2 == "+" {
                    self[p2] = d % 2 == 0 ? "|" : "-"
                } else if ch2 == "o" {
                    self[p2] = ZenLandscaperGame.parts[d2 + 4]
                    break
                }
                p2 += os
            }
        }
        
        let state = ZenLandscaperGameState(game: self)
        levelInitialized(state: state)
    }
    
}
