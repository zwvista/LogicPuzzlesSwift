//
//  CrossroadsXGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class CrossroadsXGameState: GridGameState<CrossroadsXGameMove> {
    var game: CrossroadsXGame {
        get { getGame() as! CrossroadsXGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { CrossroadsXDocument.sharedInstance }
    var objArray = [Int]()
    var pos2state = [Position: AllowedObjectState]()
    
    override func copy() -> CrossroadsXGameState {
        let v = CrossroadsXGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: CrossroadsXGameState) -> CrossroadsXGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: CrossroadsXGame, isCopy: Bool = false) {
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
    
    override func setObject(move: inout CrossroadsXGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == CrossroadsXGame.PUZ_EMPTY && self[p] != move.obj else { return .invalid }
        for p2 in game.areas[game.pos2area[p]!] {
            self[p2] = move.obj
        }
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout CrossroadsXGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == CrossroadsXGame.PUZ_EMPTY else { return .invalid }
        let o = self[p]
        move.obj = o == 9 ? CrossroadsXGame.PUZ_EMPTY : o + 1
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 3/Puzzle Set 5/Crossroads X

        Summary
        Cross at Ten

        Description
        1. Place a number in each region from 0 to 9.
        2. When four regions borders intersect (a spot where four lines meet),
           the sum of those 4 regions must be 10.
        3. No two orthogonally adjacent regions can have the same number.
    */
    private func updateIsSolved() {
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                pos2state[Position(r, c)] = .normal
            }
        }
        // 2. Two orthogonally adjacent numbers must be different.
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                for i in [1, 2] {
                    let os = CrossroadsXGame.offset[i]
                    let p2 = p + os
                    guard isValid(p: p2) && self[p] == self[p2] else {continue}
                    isSolved = false
                    pos2state[p] = .error
                    pos2state[p2] = .error
                }
            }
        }
        for area in game.areas {
            var num2rng = [Int: [Position]]()
            for p in area {
                let n = self[p]
                if n == CrossroadsXGame.PUZ_EMPTY {
                    isSolved = false
                } else {
                    num2rng[n, default: []].append(p)
                }
            }
            // 1. Fill each area with every number ranging from 1 to the size of the area.
            for (_, rng) in num2rng where rng.count > 1 {
                isSolved = false
                for p in rng { pos2state[p] = .error }
            }
            // 3. In one area, if a number is right above another, the upper one must be
            //    higher than the lower one. This only applies to numbers on top of each
            //    other in the same area.
            for p1 in area {
                for p2 in area where p1 - p2 == CrossroadsXGame.offset[0] && self[p1] <= self[p2] {
                    isSolved = false
                    pos2state[p1] = .error
                    pos2state[p2] = .error
                }
            }
        }
    }
}
