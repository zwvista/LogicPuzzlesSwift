//
//  TennerGridGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class TennerGridGame: GridGame<TennerGridGameViewController> {
    static let offset = [
        Position(1, -1),
        Position(1, 0),
        Position(1, 1),
    ]

    var objArray = [Int]()
    subscript(p: Position) -> Int {
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> Int {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    init(layout: [String], delegate: TennerGridGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length / 2)
        objArray = Array<Int>(repeating: -1, count: rows * cols)
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let s = str[c * 2...c * 2 + 1]
                let n = s == "  " ? -1 : s.toInt()!
                self[r, c] = n
            }
        }
                
        let state = TennerGridGameState(game: self)
        levelInitilized(state: state)
    }
    
    func switchObject(move: inout TennerGridGameMove) -> Bool {
        changeObject(move: &move, f: {state, move in state.switchObject(move: &move)})
    }
    
    func setObject(move: inout TennerGridGameMove) -> Bool {
        changeObject(move: &move, f: {state, move in state.setObject(move: &move)})
    }
    
}
