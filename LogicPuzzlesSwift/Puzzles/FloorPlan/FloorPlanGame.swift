//
//  FloorPlanGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class FloorPlanGame: GridGame<FloorPlanGameState> {
    static let offset = Position.Directions4
    static let PUZ_EMPTY = 0
    static let PUZ_MARKER = -1
    static let PUZ_FORBIDDEN = -2

    var objArray = [Int]()

    init(layout: [String], delegate: FloorPlanGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        objArray = Array<Int>(repeating: 0, count: rows * cols)

        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let ch = str[c]
                self[r, c] = ch == " " ? FloorPlanGame.PUZ_EMPTY : ch.toInt!
            }
        }

        let state = FloorPlanGameState(game: self)
        levelInitialized(state: state)
    }
    
    subscript(p: Position) -> Int {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> Int {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
}
