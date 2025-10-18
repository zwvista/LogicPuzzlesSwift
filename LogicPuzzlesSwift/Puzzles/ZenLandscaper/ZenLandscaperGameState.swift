//
//  ZenLandscaperGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class ZenLandscaperGameState: GridGameState<ZenLandscaperGameMove> {
    var game: ZenLandscaperGame {
        get { getGame() as! ZenLandscaperGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { ZenLandscaperDocument.sharedInstance }
    var objArray = [Character]()
    var pos2state = [Position: AllowedObjectState]()

    override func copy() -> ZenLandscaperGameState {
        let v = ZenLandscaperGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: ZenLandscaperGameState) -> ZenLandscaperGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: ZenLandscaperGame, isCopy: Bool = false) {
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
    
    override func setObject(move: inout ZenLandscaperGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == " " && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout ZenLandscaperGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == " " else { return .invalid }
        let o = self[p]
        move.obj = o == " " ? "1" : o == "3" ? " " : succ(ch: o)
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games/Puzzle Set 15/ZenLandscaper

        Summary
        Variety and Balance

        Description
        1. The Zen master has been very stressed as of late, to the point that
           yesterday he bolted for the Bahamas.
        2. The sun proved so irresistible, that he didn't even complete the
           Japanese Gardens he was working on.
        3. Being the Zen Apprentice, you are given the task to complete all of
           them following the master teaching of variety and continuity.
        4. The teaching says that any three contiguous tiles vertically,
           horizontally or diagonally must NOT be:
           -> all different
           -> all equal
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
                    let os = ZenLandscaperGame.offset[i]
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
