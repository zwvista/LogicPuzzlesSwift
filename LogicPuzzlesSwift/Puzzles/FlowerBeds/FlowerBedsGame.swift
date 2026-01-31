//
//  FlowerBedsGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class FlowerBedsGame: GridGame<FlowerBedsGameState> {
    static let offset = Position.Directions4
    static let offset2 = [
        Position(0, 0),
        Position(1, 1),
        Position(1, 1),
        Position(0, 0),
    ]
    static let dirs = [1, 0, 3, 2]
    
    var objArray = [FlowerBedsObject]()
    var hedges = [Position]()
    var flowers = [Position]()
    var dots: GridDots!
    
    init(layout: [String], delegate: FlowerBedsGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count + 1, layout[0].length + 1)
        dots = GridDots(rows: rows, cols: cols)
        objArray = Array<FlowerBedsObject>(repeating: .empty, count: rows * cols)
        
        for r in 0..<rows - 1 {
            let str = layout[r]
            for c in 0..<cols - 1 {
                let p = Position(r, c)
                switch str[c] {
                case "H":
                    self[p] = .hedge
                    hedges.append(p)
                    dots[r, c][2] = .line
                    dots[r + 1, c][0] = .line
                    dots[r, c + 1][2] = .line
                    dots[r + 1, c + 1][0] = .line
                    dots[r, c][1] = .line
                    dots[r, c + 1][3] = .line
                    dots[r + 1, c][1] = .line
                    dots[r + 1, c + 1][3] = .line
                case "F":
                    self[p] = .flower
                    flowers.append(p)
                default:
                    break
                }
            }
        }
        for r in 0..<rows - 1 {
            dots[r, 0][2] = .line
            dots[r + 1, 0][0] = .line
            dots[r, cols - 1][2] = .line
            dots[r + 1, cols - 1][0] = .line
        }
        for c in 0..<cols - 1 {
            dots[0, c][1] = .line
            dots[0, c + 1][3] = .line
            dots[rows - 1, c][1] = .line
            dots[rows - 1, c + 1][3] = .line
        }
        
        let state = FlowerBedsGameState(game: self)
        levelInitialized(state: state)
    }
    
    subscript(p: Position) -> FlowerBedsObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> FlowerBedsObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
}
