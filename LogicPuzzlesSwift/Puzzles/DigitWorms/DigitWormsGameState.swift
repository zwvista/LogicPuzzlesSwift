//
//  DigitWormsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class DigitWormsGameState: GridGameState<DigitWormsGameMove> {
    var game: DigitWormsGame {
        get { getGame() as! DigitWormsGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { DigitWormsDocument.sharedInstance }
    var objArray = [Int]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> DigitWormsGameState {
        let v = DigitWormsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: DigitWormsGameState) -> DigitWormsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: DigitWormsGame, isCopy: Bool = false) {
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
    
    override func setObject(move: inout DigitWormsGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == DigitWormsGame.PUZ_EMPTY && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout DigitWormsGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == DigitWormsGame.PUZ_EMPTY else { return .invalid }
        let o = self[p]
        move.obj = o == game.areas[game.pos2area[p]!].count ? DigitWormsGame.PUZ_EMPTY : o + 1
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 4/Puzzle Set 1/Digit Worms

        Summary
        Or a hand of worms

        Description
        1. Fill each area with numbers from 1 to the area size, putting them like
           a snake, or worm, in succession.
        2. No number must be orthogonally or diagonally touching the same number
           from another area.
    */
    private func updateIsSolved() {
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                pos2state[Position(r, c)] = .normal
            }
        }
        // 2. No number must be orthogonally or diagonally touching the same number
        //    from another area.
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let n = self[p]
                guard n != DigitWormsGame.PUZ_EMPTY else { isSolved = false; continue }
                let rng = DigitWormsGame.offset.map { p + $0 }.filter { isValid(p: $0) && self[$0] == n }
                guard !rng.isEmpty else {continue}
                isSolved = false
                for p2 in [p] + rng { pos2state[p2] = .error }
            }
        }
        next: for area in game.areas {
            var num2rng = [Int: [Position]]()
            for p in area {
                let n = self[p]
                guard n != DigitWormsGame.PUZ_EMPTY else { continue next }
                num2rng[n, default: []].append(p)
            }
            let s: HintState = num2rng.count == area.count && (1..<area.count).allSatisfy { i in DigitWormsGame.offset.contains((num2rng[i + 1]![0] - num2rng[i]![0])) } ? .complete : .error
            if s != .complete { isSolved = false }
            for (_, rng) in num2rng {
                for p in rng where pos2state[p] != .error { pos2state[p] = s }
            }
        }
    }
}
