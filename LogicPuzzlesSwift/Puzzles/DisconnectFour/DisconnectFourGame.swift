//
//  DisconnectFourGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class DisconnectFourGame: GridGame<DisconnectFourGameState> {
    static let offset = Position.Directions4

    var objArray = [DisconnectFourObject]()

    init(layout: [String], delegate: DisconnectFourGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        objArray = Array<DisconnectFourObject>(repeating: .empty, count: rows * cols)
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                switch str[c] {
                case "Y": self[r, c] = .yellow
                case "R": self[r, c] = .red
                default: break
                }
            }
        }
        
        let state = DisconnectFourGameState(game: self)
        levelInitialized(state: state)
    }
    
    subscript(p: Position) -> DisconnectFourObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> DisconnectFourObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
}
