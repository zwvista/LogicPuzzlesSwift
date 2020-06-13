//
//  SkyscrapersGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class SkyscrapersGame: GridGame<SkyscrapersGameViewController> {
    static let offset = [
        Position(-1, 0),
        Position(0, 1),
        Position(1, 0),
        Position(0, -1),
    ]

    override func isValid(row: Int, col: Int) -> Bool {
        1..<rows - 1 ~= row && 1..<cols - 1 ~= col
    }

    var objArray = [Int]()
    var intMax: Int {return rows - 2}
    subscript(p: Position) -> Int {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> Int {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    init(layout: [String], delegate: SkyscrapersGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        objArray = Array<Int>(repeating: 0, count: rows * cols)
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let ch = str[c]
                let n = ch == " " ? 0 : ch.toInt!
                self[r, c] = n
            }
        }
        
        let state = SkyscrapersGameState(game: self)
        levelInitilized(state: state)
    }
    
    func switchObject(move: inout SkyscrapersGameMove) -> Bool {
        changeObject(move: &move, f: {state, move in state.switchObject(move: &move)})
    }
    
    func setObject(move: inout SkyscrapersGameMove) -> Bool {
        changeObject(move: &move, f: {state, move in state.setObject(move: &move)})
    }
    
}
