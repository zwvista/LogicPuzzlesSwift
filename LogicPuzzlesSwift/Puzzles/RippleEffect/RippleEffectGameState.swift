//
//  RippleEffectGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class RippleEffectGameState: GridGameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: RippleEffectGame {
        get { getGame() as! RippleEffectGame }
        set { setGame(game: newValue) }
    }
    var gameDocument: RippleEffectDocument { RippleEffectDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { RippleEffectDocument.sharedInstance }
    var objArray = [Int]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> RippleEffectGameState {
        let v = RippleEffectGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: RippleEffectGameState) -> RippleEffectGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: RippleEffectGame, isCopy: Bool = false) {
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
    
    func setObject(move: inout RippleEffectGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) && game[p] == 0 && self[p] != move.obj else { return false }
        self[p] = move.obj
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout RippleEffectGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) && game[p] == 0 else { return false }
        let o = self[p]
        move.obj = (o + 1) % (game.areas[game.pos2area[p]!].count + 1)
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 5/Ripple Effect

        Summary
        Fill the Room with the numbers, but take effect of the Ripple Effect

        Description
        1. The goal is to fill the Rooms you see on the board, with numbers 1 to room size.
        2. While doing this, you must consider the Ripple Effect. The same number
           can only appear on the same row or column at the distance of the number
           itself.
        3. For example a 2 must be separated by another 2 on the same row or
           column by at least two tiles.
    */
    private func updateIsSolved() {
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                pos2state[Position(r, c)] = .normal
            }
        }
        var num2rng = [Int: [Position]]()
        func f(sameRow: Bool) {
            for (n, rng) in num2rng {
                var indexes = Set<Int>()
                for i in 0..<rng.count - 1 {
                    if sameRow ? rng[i + 1].col - rng[i].col <= n : rng[i + 1].row - rng[i].row <= n { indexes.insert(i); indexes.insert(i + 1) }
                }
                if !indexes.isEmpty { isSolved = false }
                for i in 0..<rng.count {
                    if indexes.contains(i) {
                        pos2state[rng[i]] = .error
                    }
                }
            }
        }
        for r in 0..<rows {
            num2rng.removeAll()
            for c in 0..<cols {
                let p = Position(r, c)
                let n = self[p]
                if n == 0 { isSolved = false; continue }
                var rng = num2rng[n] ?? [Position]()
                rng.append(p)
                num2rng[n] = rng
            }
            f(sameRow: true)
        }
        for c in 0..<cols {
            num2rng.removeAll()
            for r in 0..<rows {
                let p = Position(r, c)
                let n = self[p]
                if n == 0 { isSolved = false; continue }
                var rng = num2rng[n] ?? [Position]()
                rng.append(p)
                num2rng[n] = rng
            }
            f(sameRow: false)
        }
        for area in game.areas {
            num2rng.removeAll()
            for p in area {
                let n = self[p]
                guard n != 0 else {continue}
                var rng = num2rng[n] ?? [Position]()
                rng.append(p)
                num2rng[n] = rng
            }
            var anySame = false
            for (_, rng) in num2rng {
                if rng.count > 1 {
                    anySame = true
                    isSolved = false
                    for p in rng {
                        pos2state[p] = .error
                    }
                }
            }
            if !anySame {
                for p in area {
                    if pos2state[p] != .error {
                        pos2state[p] = .complete
                    }
                }
            }
        }
    }
}
