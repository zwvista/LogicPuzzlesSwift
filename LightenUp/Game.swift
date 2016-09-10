//
//  Game.swift
//  LightenUp
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum CellObject {
    case Empty
    case LightBulb
    case Wall(Int)
}

enum CellState {
    case Dark
    case Light
    case Wall
}

struct Cell {
    var obj: CellObject = .Empty
    var state: CellState = .Dark
}

class GameState {
    let rows: Int
    let cols: Int
    var cellArray: [Cell]
    
    init(rows: Int, cols: Int) {
        self.rows = rows
        self.cols = cols
        cellArray = Array<Cell>(count: rows * cols, repeatedValue: Cell())
    }
    
    subscript(row: Int, col: Int) -> Cell {
        get {
            return cellArray[row * cols + col]
        }
        set(newValue) {
            cellArray[row * cols + col] = newValue
        }
    }
    
    func setWall(row: Int, col: Int, n: Int) {
        self[row, col] = Cell(obj: .Wall(n), state: .Wall)
    }
}

class Game {
    var state: GameState
    
    init() {
        state = GameState(rows: 5, cols: 5)
        state.setWall(0, col: 2, n: -1)
        state.setWall(0, col: 4, n: -1)
        state.setWall(1, col: 3, n: 4)
        state.setWall(2, col: 2, n: 4)
        state.setWall(4, col: 1, n: 0)
    }
}
