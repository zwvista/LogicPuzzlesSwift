//
//  FieldsGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class FieldsGame: GridGame<FieldsGameState> {
    static let offset = Position.Directions4
    static let offset2 = Position.Square2x2Offset

    var objArray = [FieldsObject]()

    init(layout: [String], delegate: FieldsGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        objArray = Array<FieldsObject>(repeating: .empty, count: rows * cols)
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                switch str[c] {
                case "M": self[r, c] = .meadow
                case "S": self[r, c] = .soil
                default: break
                }
            }
        }
        
        let state = FieldsGameState(game: self)
        levelInitialized(state: state)
    }
    
    subscript(p: Position) -> FieldsObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> FieldsObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
}
