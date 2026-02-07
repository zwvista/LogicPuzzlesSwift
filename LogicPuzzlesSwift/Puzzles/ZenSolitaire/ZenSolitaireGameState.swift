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
    var objArray = [Character]()
    var pos2state = [Position: AllowedObjectState]()

    override func copy() -> ZenSolitaireGameState {
        let v = ZenSolitaireGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: ZenSolitaireGameState) -> ZenSolitaireGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: ZenSolitaireGame, isCopy: Bool = false) {
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
    
    override func setObject(move: inout ZenSolitaireGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == " " && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout ZenSolitaireGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == " " else { return .invalid }
        let o = self[p]
        move.obj = o == " " ? "1" : o == "3" ? " " : succ(ch: o)
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
                    let os = ZenSolitaireGame.offset[i]
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
