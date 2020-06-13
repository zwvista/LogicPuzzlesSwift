//
//  NorthPoleFishingGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class NorthPoleFishingGame: GridGame<NorthPoleFishingGameViewController> {
    static let offset = [
        Position(-1, 0),
        Position(0, 1),
        Position(1, 0),
        Position(0, -1),
    ]
    static let offset2 = [
        Position(0, 0),
        Position(1, 1),
        Position(1, 1),
        Position(0, 0),
    ]
    static let dirs = [1, 0, 3, 2]
    
    var objArray = [NorthPoleFishingObject]()
    var blocks = [Position]()
    var holes = [Position]()
    var dots: GridDots!
    
    init(layout: [String], delegate: NorthPoleFishingGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count + 1, layout[0].length + 1)
        dots = GridDots(rows: rows, cols: cols)
        objArray = Array<NorthPoleFishingObject>(repeating: .empty, count: rows * cols)
        
        for r in 0..<rows - 1 {
            let str = layout[r]
            for c in 0..<cols - 1 {
                let p = Position(r, c)
                switch str[c] {
                case "B":
                    self[p] = .block
                    blocks.append(p)
                    dots[r, c][2] = .line
                    dots[r + 1, c][0] = .line
                    dots[r, c + 1][2] = .line
                    dots[r + 1, c + 1][0] = .line
                    dots[r, c][1] = .line
                    dots[r, c + 1][3] = .line
                    dots[r + 1, c][1] = .line
                    dots[r + 1, c + 1][3] = .line
                case "H":
                    self[p] = .hole
                    holes.append(p)
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
        
        let state = NorthPoleFishingGameState(game: self)
        levelInitilized(state: state)
    }
    
    subscript(p: Position) -> NorthPoleFishingObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> NorthPoleFishingObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    func switchObject(move: inout NorthPoleFishingGameMove) -> Bool {
        changeObject(move: &move, f: {state, move in state.switchObject(move: &move)})
    }
    
    func setObject(move: inout NorthPoleFishingGameMove) -> Bool {
        changeObject(move: &move, f: {state, move in state.setObject(move: &move)})
    }
    
}
