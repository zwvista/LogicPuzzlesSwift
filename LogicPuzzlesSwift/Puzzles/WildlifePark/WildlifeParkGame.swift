//
//  WildlifeParkGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class WildlifeParkGame: GridGame<WildlifeParkGameState> {
    static let offset = Position.Directions4
    static let offset2 = [
        Position(0, 0),
        Position(1, 1),
        Position(1, 1),
        Position(0, 0),
    ]
    static let dirs = [1, 0, 3, 2]
    static let PUZ_POST: Character = "O"
    static let PUZ_SHEEP: Character = "S"
    static let PUZ_WOLF: Character = "W"
    
    var objArray = [GridDotObject]()
    var wolves = [Position]()
    var sheep = [Position]()
    var posts = [Position]()
    
    init(layout: [String], delegate: WildlifeParkGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count / 2 + 1, layout[0].length / 2 + 1)
        objArray = Array<GridDotObject>(repeating: Array<GridLineObject>(repeating: .empty, count: 4), count: rows * cols)
        
        for r in 0..<rows {
            var str = layout[2 * r]
            for c in 0..<cols - 1 {
                let ch = str[2 * c + 1]
                if ch == "-" {
                    self[r, c][1] = .line
                    self[r, c + 1][3] = .line
                }
                let ch2 = str[2 * c]
                guard ch2 == WildlifeParkGame.PUZ_POST else {continue}
                posts.append(Position(r, c))
            }
            guard r < rows - 1 else {break}
            str = layout[2 * r + 1]
            for c in 0..<cols {
                let ch = str[2 * c]
                if ch == "|" {
                    self[r, c][2] = .line
                    self[r + 1, c][0] = .line
                }
                guard c < cols - 1 else {continue}
                let p = Position(r, c)
                switch str[2 * c + 1] {
                case WildlifeParkGame.PUZ_WOLF: wolves.append(p)
                case WildlifeParkGame.PUZ_SHEEP: sheep.append(p)
                default: break
                }
            }
        }

        let state = WildlifeParkGameState(game: self)
        levelInitialized(state: state)
    }
    
    subscript(p: Position) -> GridDotObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> GridDotObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
}
