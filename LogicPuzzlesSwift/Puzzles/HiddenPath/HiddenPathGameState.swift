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
    var objArray = [HiddenPathObject]()
    var nextNum = 0
    var num2pos = [Int: Position]()
    
    override func copy() -> HiddenPathGameState {
        let v = HiddenPathGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: HiddenPathGameState) -> HiddenPathGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.nextNum = nextNum
        v.num2pos = num2pos
        return v
    }
    
    required init(game: HiddenPathGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array(repeating: HiddenPathObject(), count: game.maxNum)
        for i in 0..<game.maxNum {
            objArray[i].obj = game.objArray[i]
        }
        updateIsSolved()
    }
    
    subscript(p: Position) -> HiddenPathObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> HiddenPathObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout HiddenPathGameMove) -> GameChangeType {
        let p = move.p
        guard isValid(p: p) else {return .none}
        if self[p].obj == 0 {
            self[p].obj = nextNum
            updateIsSolved()
            return .level
        } else {
            updateState()
            return .internalState
        }
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
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        num2pos = [:]
        var currentPos = Position()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let n = self[p].obj
                if n == -1 { self[p].obj = 0 } // forbidden
                if n != 0 { num2pos[n] = p }
            }
        }
        nextNum = 0
        for (n, p) in num2pos {
            if n == game.maxNum {continue}
            if !num2pos.keys.contains(n + 1) {
                isSolved = false
                if nextNum == 0 {
                    currentPos = p
                    nextNum = n + 1
                }
                self[p].state = .normal
            } else {
                let p2 = num2pos[n + 1]!
                let b = game.pos2range[p]!.contains(p2)
                self[p].state = b ? .complete : .error
                if !b { isSolved = false }
                if b && n + 1 == game.maxNum {
                    self[p2].state = .complete
                }
            }
        }
        guard allowedObjectsOnly else {return}
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                guard self[p].obj == 0 else {continue}
                let b = game.pos2range[currentPos]!.contains(p)
                if !b { self[p].obj = -1 } // forbidden
            }
        }
    }
    
    private func updateState() {
        
    }
}
