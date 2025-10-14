//
//  ArrowsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class ArrowsGameState: GridGameState<ArrowsGameMove> {
    var game: ArrowsGame {
        get { getGame() as! ArrowsGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { ArrowsDocument.sharedInstance }
    var objArray = [Int]()
    var hint2state = [Position: HintState]()
    var arrow2state = [Position: AllowedObjectState]()

    override func copy() -> ArrowsGameState {
        let v = ArrowsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: ArrowsGameState) -> ArrowsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: ArrowsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
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

    override func setObject(move: inout ArrowsGameMove) -> GameOperationType {
        let p = move.p
        guard game.isBorder(p: p) && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout ArrowsGameMove) -> GameOperationType {
        let p = move.p
        guard game.isBorder(p: p) else { return .invalid }
        let o = self[p]
        move.obj = (o + 1) % 9
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games/Puzzle Set 6/Arrows

        Summary
        Just Arrows?

        Description
        1. The goal is to detect the arrows directions that reside outside the board.
        2. Each Arrow points to at least one number inside the board.
        3. The numbers tell you how many arrows point at them.
        4. There is one arrow for each tile outside the board.
    */
    private func updateIsSolved() {
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let n = self[p]
                if game.isCorner(p: p) {
                    //
                } else if game.isBorder(p: p) {
                    if n == ArrowsGame.PUZ_UNKNOWN {
                        arrow2state[p] = .normal
                    } else {
                        let os = ArrowsGame.offset[n]
                        var p2 = p + os
                        var n2 = 0
                        while isValid(p: p2) {
                            if !(game.isBorder(p: p2) || game.isCorner(p: p2)) { n2 += 1 }
                            p2 += os
                        }
                        // 2. Each Arrow points to at least one number inside the board.
                        let s: AllowedObjectState = n2 > 0 ? .normal : .error
                        arrow2state[p] = s
                        if s == .error { isSolved = false }
                    }
                } else {
                    var n2 = 0
                    for i in 0..<8 {
                        let os = ArrowsGame.offset[i]
                        var p2 = p + os
                        while isValid(p: p2) {
                            if game.isBorder(p: p2) && self[p2] == (i + 4) % 8 { n2 += 1 }
                            p2 += os
                        }
                    }
                    // 3. The numbers tell you how many arrows point at them.
                    let s: HintState = n2 < n ? .normal : n2 == n ? .complete : .error
                    hint2state[p] = s
                    if s != .complete { isSolved = false }
                }
            }
        }
    }
}
