//
//  GameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol GameStateBase: class {
    var isSolved: Bool {get}
}

class GameState: Copyable, GameStateBase {
    var isSolved = false
    
    func copy() -> GameState {
        let v = GameState()
        return setup(v: v)
    }
    func setup(v: GameState) -> GameState {
        v.isSolved = isSolved
        return v
    }
}

class CellsGameState: GameState {
    unowned let gameBase: CellsGameBase
    var size: Position { return gameBase.size }
    var rows: Int { return size.row }
    var cols: Int { return size.col }
    func isValid(p: Position) -> Bool {
        return gameBase.isValid(row: p.row, col: p.col)
    }
    func isValid(row: Int, col: Int) -> Bool {
        return gameBase.isValid(row: row, col: col)
    }
    
    override func copy() -> CellsGameState {
        let v = CellsGameState(game: gameBase)
        return setup(v: v)
    }
    func setup(v: CellsGameState) -> CellsGameState {
        _ = super.setup(v: v)
        return v
    }
    
    required init(game: CellsGameBase) {
        self.gameBase = game
    }
}
