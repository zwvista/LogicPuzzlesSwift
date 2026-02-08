//
//  ZenSolitaireGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class ZenSolitaireGameState: GridGameState<ZenSolitaireGameMove> {
    var game: ZenSolitaireGame {
        get { getGame() as! ZenSolitaireGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { ZenSolitaireDocument.sharedInstance }
    var objArray = [Int]()
    var lastMove: ZenSolitaireGameMove? = nil

    override func copy() -> ZenSolitaireGameState {
        let v = ZenSolitaireGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: ZenSolitaireGameState) -> ZenSolitaireGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.lastMove = lastMove
        return v
    }
    
    required init(game: ZenSolitaireGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<Int>(repeating: ZenSolitaireGame.PUZ_EMPTY, count: rows * cols)
        for p in game.stones {
            self[p] = ZenSolitaireGame.PUZ_STONE
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
    
    override func setObject(move: inout ZenSolitaireGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && self[p] == ZenSolitaireGame.PUZ_STONE else { return .invalid }
        self[p] = move.obj
        lastMove = move
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout ZenSolitaireGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && self[p] == ZenSolitaireGame.PUZ_STONE else { return .invalid }
        // 3. From a stone, you can move horizontally or vertically to the next stone. You can't
        //    jump over stones, if you encounter it, you have to pick it up.
        // 5. when a stone has been picked up, you can pass away it if you encounter it again
        //    (it's not there anymore).
        func f(p1: Position, p2: Position) -> (Bool, Int) {
            let (r1, c1) = p1.destructured
            let (r2, c2) = p2.destructured
            guard r1 == r2 || c1 == c2 else { return (false, -1) }
            let os = Position((r2 - r1).signum(), (c2 - c1).signum())
            var p3 = p1 + os
            while p3 != p2 {
                guard self[p3] != ZenSolitaireGame.PUZ_STONE else { return (false, -1) }
                p3 += os
            }
            let dir = ZenGardensGame.offset.indexes(of: os).first!
            return (true, dir)
        }
        // 2. You can start at any stone and pick it up (just to click on it and it will be numbered
        //    in the order you pick it up).
        if lastMove == nil {
            move.dir = -1
            move.obj = 1
        } else {
            let (ok, dir) = f(p1: lastMove!.p, p2: p)
            // 4. When moving from a stone to another, you can change direction, but you cannot reverse it.
            guard ok && dir != (lastMove!.dir + 2) % 4 else { return .invalid }
            move.dir = dir
            move.obj = lastMove!.obj + 1
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 2/Zen Solitaire

        Summary
        Pick up stones

        Description
         1. A favorite Zen Master pastime, scattering stones on the sand and picking them up.
         2. You can start at any stone and pick it up (just to click on it and it will be numbered
            in the order you pick it up).
         3. From a stone, you can move horizontally or vertically to the next stone. You can't
            jump over stones, if you encounter it, you have to pick it up.
         4. When moving from a stone to another, you can change direction, but you cannot reverse it.
         5. when a stone has been picked up, you can pass away it if you encounter it again
            (it's not there anymore).
         6. The goal is to pick up every stone.
    */
    private func updateIsSolved() {
        isSolved = true
        // 6. The goal is to pick up every stone.
        for r in 0..<rows {
            for c in 0..<cols {
                guard self[r, c] != ZenSolitaireGame.PUZ_STONE else { isSolved = false; return }
            }
        }
    }
}
