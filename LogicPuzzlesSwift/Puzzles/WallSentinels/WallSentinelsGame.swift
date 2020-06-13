//
//  WallSentinelsGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class WallSentinelsGame: GridGame<WallSentinelsGameViewController> {
    static let offset = [
        Position(-1, 0),
        Position(0, 1),
        Position(1, 0),
        Position(0, -1),
    ]
    static let offset2 = [
        Position(0, 0),
        Position(0, 1),
        Position(1, 0),
        Position(1, 1),
    ]

    var objArray = [WallSentinelsObject]()

    init(layout: [String], delegate: WallSentinelsGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length / 2)
        objArray = Array<WallSentinelsObject>(repeating: .empty, count: rows * cols)

        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let s = str[c * 2...c * 2 + 1]
                guard s != "  " else {continue}
                let n = s[1].toInt!
                self[r, c] = s[0] == "." ? .hintLand(tiles: n, state: .normal) : .hintWall(tiles: n, state: .normal)
            }
        }
        
        let state = WallSentinelsGameState(game: self)
        levelInitilized(state: state)
    }
    
    subscript(p: Position) -> WallSentinelsObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> WallSentinelsObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    func switchObject(move: inout WallSentinelsGameMove) -> Bool {
        changeObject(move: &move, f: {state, move in state.switchObject(move: &move)})
    }
    
    func setObject(move: inout WallSentinelsGameMove) -> Bool {
        changeObject(move: &move, f: {state, move in state.setObject(move: &move)})
    }
    
}
