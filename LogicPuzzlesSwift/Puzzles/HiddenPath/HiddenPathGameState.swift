//
//  HiddenPathGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class HiddenPathGameState: GridGameState<HiddenPathGameMove> {
    var game: HiddenPathGame {
        get { getGame() as! HiddenPathGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { HiddenPathDocument.sharedInstance }
    var objArray = [Int]()
    var pos2state = [Position: HintState]()
    var nextNum = 0
    
    override func copy() -> HiddenPathGameState {
        let v = HiddenPathGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: HiddenPathGameState) -> HiddenPathGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        v.nextNum = nextNum
        return v
    }
    
    required init(game: HiddenPathGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        for r in 0..<rows {
            for c in 0..<cols {
                pos2state[Position(r, c)] = .normal
            }
        }
        updateIsSolved()
    }
    
    subscript(p: Position) -> Int {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> Int {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout HiddenPathGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) && self[p] == 0 else { return false }
        self[p] = nextNum
        updateIsSolved()
        return true
    }

    
    /*
        iOS Game: 100 Logic Games/Puzzle Set 3/Hidden Path

        Summary
        Jump once on every tile, following the arrows

        Description
        Starting at the tile number 1, reach the last tile by jumping from tile to tile.
        1. When jumping from a tile, you have to follow the direction of the arrow and
           land on a tile in that direction
        2. Although you have to follow the direction of the arrow, you can land on any
           tile in that direction, not just the one next to the current tile.
        3. The goal is to jump on every tile, only once and reach the last tile.
    */
    private func updateIsSolved() {
        isSolved = true
        var num2pos = [Int: Position]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let n = self[p]
                if n != 0 {
                    num2pos[n] = p
                }
            }
        }
        nextNum = 0
        for (n, p) in num2pos {
            if n == game.maxNum {continue}
            if !num2pos.keys.contains(n + 1) {
                isSolved = false
                if nextNum == 0 {
                    nextNum = n + 1
                }
                pos2state[p] = .normal
            } else {
                let d = num2pos[n + 1]! - p
                let os = HiddenPathGame.offset[game.pos2hint[p]!]
                let b = d.row.signum() == os.row && d.col.signum() == os.col
                pos2state[p] = b ? .complete : .error
                if !b {
                    isSolved = false
                }
            }
        }
    }
}
