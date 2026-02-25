//
//  TopArrowGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class TopArrowGameState: GridGameState<TopArrowGameMove> {
    var game: TopArrowGame {
        get { getGame() as! TopArrowGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { TopArrowDocument.sharedInstance }
    var objArray = [Int]()
    var pos2state = [Position: AllowedObjectState]()
    
    override func copy() -> TopArrowGameState {
        let v = TopArrowGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: TopArrowGameState) -> TopArrowGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: TopArrowGame, isCopy: Bool = false) {
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
    
    override func setObject(move: inout TopArrowGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == TopArrowGame.PUZ_EMPTY && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout TopArrowGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == TopArrowGame.PUZ_EMPTY else { return .invalid }
        let o = self[p]
        move.obj = o == game.areas[game.pos2area[p]!].count ? TopArrowGame.PUZ_EMPTY : o + 1
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 3/Top Arrow

        Summary
        Top numbers

        Description
        1. Fill each area with each of the digits from 1 to the size of the
           area itself.
        2. Arrows point to the biggest number around it in the four directions
           (up, left, down, right).
        3. When two numbers are orthogonally adjacent across areas, the numbers
           must be different.
        4. There can't be ties for the biggest number in the four directions.
    */
    private func updateIsSolved() {
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                pos2state[Position(r, c)] = .normal
            }
        }
        // 3. When two numbers are orthogonally adjacent across areas, the numbers
        //    must be different.
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                for i in [1, 2] {
                    let os = TopArrowGame.offset[i]
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
                if n == TopArrowGame.PUZ_EMPTY {
                    isSolved = false
                } else {
                    num2rng[n, default: []].append(p)
                }
            }
            // 1. Fill each area with each of the digits from 1 to the size of the
            //    area itself.
            for (_, rng) in num2rng where rng.count > 1 {
                isSolved = false
                for p in rng { pos2state[p] = .error }
            }
        }
        // 2. Arrows point to the biggest number around it in the four directions
        //    (up, left, down, right).
        // 4. There can't be ties for the biggest number in the four directions.
        hint: for (p, d) in game.pos2hint {
            var dir2num = [Int: Int]()
            for (d2, os) in TopArrowGame.offset.enumerated() {
                let p2 = p + os
                guard isValid(p: p2) else {continue}
                let o = self[p2]
                guard o != TopArrowGame.PUZ_EMPTY else { continue hint }
                guard o != TopArrowGame.PUZ_HINT && o != TopArrowGame.PUZ_BLOCK else {continue}
                dir2num[d2] = o
            }
            let (d3, n) = dir2num.max { $0.value < $1.value }!
            let s: AllowedObjectState = d3 == d && (dir2num.count { $0.value == n }) == 1 ? .normal : .error
            pos2state[p] = s
            if s == .error { isSolved = false }
        }
    }
}
