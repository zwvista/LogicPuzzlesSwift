//
//  HidokuGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation
import OrderedCollections

class HidokuGameState: GridGameState<HidokuGameMove> {
    var game: HidokuGame {
        get { getGame() as! HidokuGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { HidokuDocument.sharedInstance }
    var objArray = [HidokuObject]()
    var nextNum = 0
    var num2pos = OrderedDictionary<Int, Position>()
    var focusPos: Position!
    var hintPos: Position? = nil

    override func copy() -> HidokuGameState {
        let v = HidokuGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: HidokuGameState) -> HidokuGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.nextNum = nextNum
        v.num2pos = num2pos
        v.focusPos = focusPos
        v.hintPos = hintPos
        return v
    }
    
    required init(game: HidokuGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array(repeating: HidokuObject(), count: game.maxNum)
        for i in 0..<game.maxNum {
            objArray[i].obj = game.objArray[i]
        }
        updateIsSolved()
        updateState()
    }
    
    subscript(p: Position) -> HidokuObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> HidokuObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout HidokuGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) else {return .invalid}
        switch self[p].obj {
        case 0:
            self[p].obj = nextNum
            focusPos = p
            updateIsSolved()
            updateState()
            return .moveComplete
        case -1:
            return .invalid
        default:
            focusPos = p
            updateState()
            return .partialMove
        }
    }

    
    /*
        iOS Game: 100 Logic Games/Puzzle Set 4/Hidoku

        Summary
        Jump from one neighboring tile to another and fill the board

        Description
        1. Starting at the tile number 1, reach the last tile by jumping from
           tile to tile.
        2. When jumping from a tile, you can land on any tile around it,
           horizontally, vertically or diagonally touching.
        3. The goal is to jump on every tile, only once and reach the last tile.
    */
    private func updateIsSolved() {
        isSolved = true
        num2pos = [:]
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let n = self[p].obj
                if n == -1 { self[p].obj = 0 } // forbidden
                if n != 0 && n != -1 { num2pos[n] = p }
            }
        }
        num2pos.sort()
        if focusPos == nil {
            focusPos = num2pos[1]!
        }
        for (n, p) in num2pos {
            if n == game.maxNum {continue}
            if !num2pos.keys.contains(n + 1) {
                isSolved = false
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
    }
    
    private func updateState() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        var currentNum = self[focusPos].obj
        hintPos = num2pos.first { k, _ in k > currentNum }?.value
        var currentPos = focusPos!
        nextNum = 0
        for (n, p) in num2pos {
            if n == game.maxNum {continue}
            if currentNum + 1 == n && nextNum == 0 {
                currentNum = n
            }
            if !num2pos.keys.contains(n + 1) && currentNum == n && nextNum == 0 {
                currentPos = p
                nextNum = n + 1
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
}
