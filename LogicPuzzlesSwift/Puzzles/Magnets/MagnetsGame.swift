//
//  MagnetsGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class MagnetsGame: GridGame<MagnetsGameViewController> {
    static let offset = [
        Position(-1, 0),
        Position(0, 1),
        Position(1, 0),
        Position(0, -1),
    ]

    var row2hint = [Int]()
    var col2hint = [Int]()
    var areas = [MagnetsArea]()
    var singles = [Position]()
    
    init(layout: [String], delegate: MagnetsGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count - 2, layout[0].length - 2)
        row2hint = Array<Int>(repeating: 0, count: rows * 2)
        col2hint = Array<Int>(repeating: 0, count: cols * 2)
        
        for r in 0..<rows + 2 {
            let str = layout[r]
            for c in 0..<cols + 2 {
                let p = Position(r, c)
                let ch = str[c]
                switch ch {
                case "0"..."9":
                    let n = ch.toInt!
                    if r >= rows {
                        col2hint[2 * c + r - rows] = n
                    } else if c >= cols {
                        row2hint[2 * r + c - cols] = n
                    }
                case ".":
                    areas.append(MagnetsArea(p: p, type: .single))
                    singles.append(p)
                case "H":
                    areas.append(MagnetsArea(p: p, type: .horizontal))
                case "V":
                    areas.append(MagnetsArea(p: p, type: .vertical))
                default:
                    break
                }
            }
        }
        
        let state = MagnetsGameState(game: self)
        levelInitilized(state: state)
    }
    
}
