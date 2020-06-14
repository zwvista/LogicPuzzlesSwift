//
//  NumberCrosswordsGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class NumberCrosswordsGame: GridGame<NumberCrosswordsGameState> {
    static let offset = [
        Position(-1, 0),
        Position(0, 1),
        Position(1, 0),
        Position(0, -1),
    ]
    
    override func isValid(row: Int, col: Int) -> Bool {
        0..<rows - 1 ~= row && 0..<cols - 1 ~= col
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
    
    init(layout: [String], delegate: NumberCrosswordsGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length / 2)
        objArray = Array<Int>(repeating: 0, count: rows * cols)
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let s = str[c * 2...c * 2 + 1]
                guard s != "  " else {continue}
                let n = s.toInt()!
                self[r, c] = n
            }
        }
                
        let state = NumberCrosswordsGameState(game: self)
        levelInitilized(state: state)
    }
    
}
