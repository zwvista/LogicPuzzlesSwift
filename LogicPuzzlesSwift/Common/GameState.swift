//
//  GameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol GameStateBase: Copyable {
    associatedtype GM
    var isSolved: Bool { get }
    func setObject(move: inout GM) -> Bool
    func switchObject(move: inout GM) -> Bool
}

class GameState<GM>: GameStateBase {
    var isSolved = false
    
    func copy() -> GameState {
        let v = GameState()
        return setup(v: v)
    }
    func setup(v: GameState) -> GameState {
        v.isSolved = isSolved
        return v
    }
    func setObject(move: inout GM) -> Bool { false }
    func switchObject(move: inout GM) -> Bool { false }
    deinit {
        // print("deinit called: \(NSStringFromClass(type(of: self)))")
    }
}

class GridGameState<GM>: GameState<GM> {
    private weak var game: GridGameBase!
    func getGame() -> GridGameBase { game }
    func setGame(game: GridGameBase) { self.game = game }
    var gameDocument: GameDocumentBase! { nil }
    var gameOptions: GameProgress { gameDocument.gameProgress }
    var markerOption: Int { gameOptions.option1?.toInt() ?? 0 }
    var allowedObjectsOnly: Bool { gameOptions.option2?.toBool() ?? false }
    
    var size: Position { game!.size }
    var rows: Int { size.row }
    var cols: Int { size.col }
    func isValid(p: Position) -> Bool {
        game.isValid(row: p.row, col: p.col)
    }
    func isValid(row: Int, col: Int) -> Bool {
        game.isValid(row: row, col: col)
    }
    
    override func copy() -> GridGameState {
        let v = GridGameState(game: game)
        return setup(v: v)
    }
    func setup(v: GridGameState) -> GridGameState {
        _ = super.setup(v: v)
        return v
    }
    
    init(game: GridGameBase) {
        self.game = game
    }
    
    func succ(ch: Character, offset: Int = 1) -> Character {
        // http://stackoverflow.com/questions/26761390/changing-value-of-character-using-ascii-value-in-swift
        let scalars = String(ch).unicodeScalars      // unicode scalar(s) of the character
        let val = scalars[scalars.startIndex].value  // value of the unicode scalar
        return Character(UnicodeScalar(UInt32(Int(val) + offset))!)     // return an incremented character
    }
}
