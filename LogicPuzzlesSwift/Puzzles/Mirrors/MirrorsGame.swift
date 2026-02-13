//
//  MirrorsGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class MirrorsGame: GridGame<MirrorsGameState> {
    static let offset = Position.Directions4

    var objArray = [MirrorsObject]()
    subscript(p: Position) -> MirrorsObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> MirrorsObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    init(layout: [String], delegate: MirrorsGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        objArray = Array<MirrorsObject>(repeating: MirrorsObject(), count: rows * cols)

        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let ch = str[c]
                self[r, c] = switch ch {
                case "O": .block
                case "3": .upRight
                case "6": .downRight
                case "C": .downLeft
                case "9": .upLeft
                case "A": .horizontal
                case "5": .vertical
                default: .empty
                }
            }
        }
        let state = MirrorsGameState(game: self)
        levelInitialized(state: state)
    }
}
