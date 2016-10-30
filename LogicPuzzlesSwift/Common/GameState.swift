//
//  BridgesGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class GameState: Copyable {
    private(set) var isSolved = false
    required init(x: GameState) {
        isSolved = x.isSolved
    }
}

class CellsGameState<G: CellsGame<Any, GD, Any, GS>, GD: GameDelegate, GS: GameState> : GameState
    where GD.G == G, GD.GS == GS {
    let game: G!
    var size: Position { return game.size }
    var rows: Int { return size.row }
    var cols: Int { return size.col }
    func isValid(p: Position) -> Bool {
        return game.isValid(row: p.row, col: p.col)
    }
    func isValid(row: Int, col: Int) -> Bool {
        return game.isValid(row: row, col: col)
    }
    
    required init(x: CellsGameState) {
        super.init(x)
        game = x.game
    }
}
