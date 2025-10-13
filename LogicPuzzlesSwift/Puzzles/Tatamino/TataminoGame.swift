//
//  TataminoGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class TataminoGame: GridGame<TataminoGameState> {
    static let offset = Position.Directions4
    static let offset2 = [
        Position(0, 0),
        Position(0, 1),
        Position(1, 0),
        Position(0, 0),
    ]
    static let dirs = [1, 2, 1, 2]

    var areas = [[Position]]()
    var pos2area = [Position: Int]()
    var dots: GridDots!
    var objArray = [Character]()
    
    init(layout: [String], delegate: TataminoGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        dots = GridDots(rows: rows + 1, cols: cols + 1)
        objArray = Array<Character>(repeating: " ", count: rows * cols)
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                self[r, c] = str[c]
            }
        }
        for r in 0..<rows {
            dots[r, 0][2] = .line
            dots[r, cols][2] = .line
        }
        for c in 0..<cols {
            dots[0, c][1] = .line
            dots[rows, c][1] = .line
        }

        let state = TataminoGameState(game: self)
        levelInitialized(state: state)
    }
    
    subscript(p: Position) -> Character {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> Character {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
}
