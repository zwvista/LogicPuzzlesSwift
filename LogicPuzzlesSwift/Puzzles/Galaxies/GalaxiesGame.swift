//
//  GalaxiesGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class GalaxiesGame: GridGame<GalaxiesGameViewController> {
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
    
    var objArray = [GridDotObject]()
    var galaxies = Set<Position>()
    
    init(layout: [String], delegate: GalaxiesGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count + 1, layout[0].length + 1)
        objArray = Array<GridDotObject>(repeating: Array<GridLineObject>(repeating: .empty, count: 4), count: rows * cols)

        for r in 0..<rows - 1 {
            let str = layout[r]
            for c in 0..<cols - 1 {
                switch str[c] {
                case "o":
                    galaxies.insert(Position(r * 2 + 1, c * 2 + 1))
                case "v":
                    galaxies.insert(Position(r * 2 + 2, c * 2 + 1))
                    self[r + 1, c][1] = .forbidden
                    self[r + 1, c + 1][3] = .forbidden
                case ">":
                    galaxies.insert(Position(r * 2 + 1, c * 2 + 2))
                    self[r, c + 1][2] = .marker
                    self[r + 1, c + 1][0] = .forbidden
                case "x":
                    galaxies.insert(Position(r * 2 + 2, c * 2 + 2))
                    self[r, c + 1][2] = .forbidden
                    self[r + 1, c + 1][0] = .forbidden
                    self[r + 1, c][1] = .forbidden
                    self[r + 1, c + 1][3] = .forbidden
                    self[r + 1, c + 1][1] = .forbidden
                    self[r + 1, c + 2][3] = .forbidden
                    self[r + 1, c + 1][2] = .forbidden
                    self[r + 2, c + 1][0] = .forbidden
                default:
                    break
                }
            }
        }
        for r in 0..<rows - 1 {
            self[r, 0][2] = .line
            self[r + 1, 0][0] = .line
            self[r, cols - 1][2] = .line
            self[r + 1, cols - 1][0] = .line
        }
        for c in 0..<cols - 1 {
            self[0, c][1] = .line
            self[0, c + 1][3] = .line
            self[rows - 1, c][1] = .line
            self[rows - 1, c + 1][3] = .line
        }
        
        let state = GalaxiesGameState(game: self)
        levelInitilized(state: state)
    }
    
    subscript(p: Position) -> GridDotObject {
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> GridDotObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func switchObject(move: inout GalaxiesGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.switchObject(move: &move)})
    }
    
    func setObject(move: inout GalaxiesGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.setObject(move: &move)})
    }
    
}
