//
//  PlanetsGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class PlanetsGame: GridGame<PlanetsGameState> {
    static let offset = Position.Directions4
    static let chars = " 01392846C"
    static let isLitDict: [[Int]: PlanetsObject] = [
        []: .none,
        [0]: .north,
        [1]: .east,
        [2]: .south,
        [3]: .west,
        [0, 1]: .northEast,
        [0, 3]: .northWest,
        [1, 2]: .southEast,
        [2, 3]: .southWest,
    ]

    var objArray = [PlanetsObject]()
    var planets = [Position]()

    init(layout: [String], delegate: PlanetsGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        objArray = Array<PlanetsObject>(repeating: .empty, count: rows * cols)
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let ch = str[c]
                let p = Position(r, c)
                self[p] = PlanetsObject(rawValue: PlanetsGame.chars.getIndexOf(ch)!)!
                if ch != " " {
                    planets.append(p)
                }
            }
        }

        let state = PlanetsGameState(game: self)
        levelInitialized(state: state)
    }
    
    subscript(p: Position) -> PlanetsObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> PlanetsObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
}
