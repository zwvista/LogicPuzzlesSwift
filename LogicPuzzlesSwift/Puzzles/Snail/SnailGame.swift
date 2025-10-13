//
//  SnailGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class SnailGame: GridGame<SnailGameState> {
    static let offset = Position.Directions4

    var objArray = [Character]()
    var snailPathGrid = [Position]()
    var snailPathLine = [Position]()
    
    init(layout: [String], delegate: SnailGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        objArray = Array<Character>(repeating: " ", count: rows * cols)
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let ch = str[c]
                self[r, c] = ch
            }
        }
        
        func snailPath(n: Int) -> [Position] {
            var path = [Position]()
            var rng = Set<Position>()
            for r in 0..<n {
                for c in 0..<n {
                    rng.insert(Position(r, c))
                }
            }
            var p = Position(0, -1)
            var dir = 1
            while !rng.isEmpty {
                let p2 = p + SnailGame.offset[dir]
                if rng.contains(p2) {
                    p = p2
                    rng.remove(p)
                } else {
                    dir = (dir + 1) % 4
                    p += SnailGame.offset[dir]
                    rng.remove(p)
                }
                path.append(p)
            }
            return path
        }
        snailPathGrid = snailPath(n: rows)
        snailPathLine = snailPath(n: rows + 1)
        
        let state = SnailGameState(game: self)
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
