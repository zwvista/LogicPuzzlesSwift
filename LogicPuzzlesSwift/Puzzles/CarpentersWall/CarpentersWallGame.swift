//
//  CarpentersWallGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class CarpentersWallGame: GridGame<CarpentersWallGameState> {
    static let offset = Position.Directions4
    static let offset2 = [
        Position(0, 0),
        Position(0, 1),
        Position(1, 0),
        Position(1, 1),
    ]

    var objArray = [CarpentersWallObject]()

    init(layout: [String], delegate: CarpentersWallGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        objArray = Array<CarpentersWallObject>(repeating: .empty, count: rows * cols)
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let p = Position(r, c)
                let ch = str[c]
                switch ch {
                case "0"..."9": self[p] = .corner(tiles: ch.toInt!, state: .normal)
                case "O": self[p] = .corner(tiles: 0, state: .normal)
                case "^": self[p] = .up(state: .normal)
                case "v": self[p] = .down(state: .normal)
                case "<": self[p] = .left(state: .normal)
                case ">": self[p] = .right(state: .normal)
                default: break
                }
            }
        }
        
        let state = CarpentersWallGameState(game: self)
        levelInitialized(state: state)
    }
    
    subscript(p: Position) -> CarpentersWallObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> CarpentersWallObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
}
