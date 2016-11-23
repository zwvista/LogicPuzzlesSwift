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
    deinit {
        // print("deinit called: \(NSStringFromClass(type(of: self)))")
    }
}

class CellsGameState: GameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    private weak var game: CellsGameBase?
    func getGame() -> CellsGameBase? {return game}
    func setGame(game: CellsGameBase) {self.game = game}
    
    var size: Position { return game!.size }
    var rows: Int { return size.row }
    var cols: Int { return size.col }
    func isValid(p: Position) -> Bool {
        return game!.isValid(row: p.row, col: p.col)
    }
    func isValid(row: Int, col: Int) -> Bool {
        return game!.isValid(row: row, col: col)
    }
    
    override func copy() -> CellsGameState {
        let v = CellsGameState(game: game)
        return setup(v: v)
    }
    func setup(v: CellsGameState) -> CellsGameState {
        _ = super.setup(v: v)
        return v
    }
    
    init(game: CellsGameBase?) {
        self.game = game
    }
}
