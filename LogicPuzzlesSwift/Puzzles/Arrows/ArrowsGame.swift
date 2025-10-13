//
//  ArrowsGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class ArrowsGame: GridGame<ArrowsGameState> {
    static let PUZ_UNKNOWN = 8
    static let offset = Position.Directions4

    override func isValid(row: Int, col: Int) -> Bool {
        1..<rows - 1 ~= row && (col == 0 || col == cols - 1) ||
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
    
    init(layout: [String], delegate: ArrowsGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count + 2, layout[0].length + 2)
        objArray = Array(repeating: -1, count: rows * cols)
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let ch = str[c]
                self[r, c] = ch.toInt!
            }
        }
        
        let state = ArrowsGameState(game: self)
        levelInitialized(state: state)
    }
    
}
