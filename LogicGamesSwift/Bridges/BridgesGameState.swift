//
//  BridgesGameState.swift
//  LogicGamesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

struct BridgesGameState {
    let game: BridgesGame
    var size: Position { return game.size }
    var rows: Int { return size.row }
    var cols: Int { return size.col }
    func isValid(p: Position) -> Bool {
        return game.isValid(row: p.row, col: p.col)
    }
    func isValid(row: Int, col: Int) -> Bool {
        return game.isValid(row: row, col: col)
    }
    var objArray = [BridgesObject]()
    var options: BridgesGameProgress { return BridgesDocument.sharedInstance.gameProgress }
    
    init(game: BridgesGame) {
        self.game = game
        objArray = Array<BridgesObject>(repeating: BridgesObject(), count: rows * cols)
    }
    
    subscript(p: Position) -> BridgesObject {
        get {
            return objArray[p.row * cols + p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> BridgesObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    
    private(set) var isSolved = false
    
    private mutating func updateIsSolved() {
        isSolved = true
    }
}
