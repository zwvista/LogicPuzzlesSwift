//
//  PointingGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class PointingGame: GridGame<PointingGameState> {
    static let PUZ_UNKNOWN = 8
    static let offset = Position.Directions8
    
    func isCorner(p: Position) -> Bool {
        let (row, col) = p.destructured
        return (row == 0 || row == rows - 1) && (col == 0 || col == cols - 1)
    }
    
    func isBorder(p: Position) -> Bool {
        let (row, col) = p.destructured
        return 1..<rows - 1 ~= row && (col == 0 || col == cols - 1) ||
            1..<cols - 1 ~= col && (row == 0 || row == rows - 1)
    }

    var objArray = [Int]()
    subscript(p: Position) -> Int {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> Int {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    init(layout: [String], delegate: PointingGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count + 2, layout[0].length + 2)
        objArray = Array(repeating: PointingGame.PUZ_UNKNOWN, count: rows * cols)
        
        for r in 1..<rows - 1 {
            let str = layout[r - 1]
            for c in 1..<cols - 1 {
                let ch = str[c - 1]
                self[r, c] = ch.toInt!
            }
        }
        
        let state = PointingGameState(game: self)
        levelInitialized(state: state)
    }
    
}
