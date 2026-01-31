//
//  PointingGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class PointingGameState: GridGameState<PointingGameMove> {
    var game: PointingGame {
        get { getGame() as! PointingGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { PointingDocument.sharedInstance }
    var objArray = [Int]()
    var hint2state = [Position: HintState]()
    var arrow2state = [Position: AllowedObjectState]()

    override func copy() -> PointingGameState {
        let v = PointingGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: PointingGameState) -> PointingGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: PointingGame, isCopy: Bool = false) {
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

    override func setObject(move: inout PointingGameMove) -> GameOperationType {
        let p = move.p
        guard game.isBorder(p: p) && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout PointingGameMove) -> GameOperationType {
        let p = move.p
        guard game.isBorder(p: p) else { return .invalid }
        let o = self[p]
        move.obj = (o + 1) % 9
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 3/Puzzle Set 2/Pointing

        Summary
        Are you pointing to me?

        Description
        1. Mark some arrows so that each arrow points to exactly one marked arrow.
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
                    if n == PointingGame.PUZ_UNKNOWN {
                        arrow2state[p] = .normal
                    } else {
                        let os = PointingGame.offset[n]
                        var p2 = p + os
                        var n2 = 0
                        while isValid(p: p2) {
                            if !(game.isCorner(p: p2) || game.isBorder(p: p2)) { n2 += 1 }
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
                        let os = PointingGame.offset[i]
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
