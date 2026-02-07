//
//  ZenGardensGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class ZenGardensGameState: GridGameState<ZenGardensGameMove> {
    var game: ZenGardensGame {
        get { getGame() as! ZenGardensGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { ZenGardensDocument.sharedInstance }
    var objArray = [Character]()
    var pos2state = [Position: AllowedObjectState]()

    override func copy() -> ZenGardensGameState {
        let v = ZenGardensGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: ZenGardensGameState) -> ZenGardensGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: ZenGardensGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        updateIsSolved()
    }
    
    subscript(p: Position) -> Character {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> Character {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout ZenGardensGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == " " && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout ZenGardensGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == " " else { return .invalid }
        let o = self[p]
        move.obj = o == " " ? "1" : o == "3" ? " " : succ(ch: o)
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 3/Zen Gardens

        Summary
        Many Zen Masters

        Description
        1. Put a leaf on every Zen Garden (area).
        2. A Leaf can only be on a Rock.
        3. Three Rocks in a row (horizontally, vertically or diagonally) can't
           have all the leaves or no leaves.
    */
    private func updateIsSolved() {
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                pos2state[Position(r, c)] = .normal
            }
        }
        // 4. The teaching says that any three contiguous tiles vertically,
        //    horizontally or diagonally must NOT be:
        //    -> all different
        //    -> all equal
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                for i in 2...4 {
                    let os = ZenGardensGame.offset[i]
                    var tiles = [p]
                    var p2 = p + os
                    for _ in 1..<3 {
                        guard isValid(p: p2) else {break}
                        tiles.append(p2)
                        p2 += os
                    }
                    if tiles.count < 3 {continue}
                    let chSet = Set(tiles.map { self[$0] })
                    if chSet.contains(" ") {
                        isSolved = false
                        continue
                    }
                    if chSet.count != 2 {
                        isSolved = false
                        for p2 in tiles {
                            pos2state[p2] = .error
                        }
                    }
                }
            }
        }
    }
}
