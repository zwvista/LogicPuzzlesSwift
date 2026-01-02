//
//  PouringWaterGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class PouringWaterGameState: GridGameState<PouringWaterGameMove> {
    var game: PouringWaterGame {
        get { getGame() as! PouringWaterGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { PouringWaterDocument.sharedInstance }
    var objArray = [Character]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> PouringWaterGameState {
        let v = PouringWaterGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: PouringWaterGameState) -> PouringWaterGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: PouringWaterGame, isCopy: Bool = false) {
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
    
    override func setObject(move: inout PouringWaterGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == " " && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout PouringWaterGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == " " else { return .invalid }
        let o = self[p]
        move.obj =
            o == " " ? "1" :
            o == "3" ? " " :
            succ(ch: o)
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 3/Pouring Water

        Summary
        Communicating Vessels

        Description
        1. The board represents some communicating vessels.
        2. You have to fill some water in it, considering that water pours down
           and levels itself like in reality.
        3. Areas of the same level which are horizontally connected will have
           the same water level.
        4. The numbers on the border show you how many tiles of each row and
           column are filled.
    */
    private func updateIsSolved() {
        isSolved = true
        let chars2: [Character] = ["1", "2", "3"]
        let chars3 = chars2.flatMap { Array<Character>(repeating: $0, count: rows / 3) }
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                if self[p] == " " { isSolved = false }
                pos2state[p] = .normal
            }
        }
        for r in 0..<rows {
            var lineSolved = true
            for c in 0..<cols - 1 {
                let (p1, p2) = (Position(r, c), Position(r, c + 1))
                let (ch1, ch2) = (self[p1], self[p2])
                guard ch1 != " " && ch2 != " " && ch1 == ch2 else {continue}
                // 4. You can't have two identical numbers touching horizontally.
                isSolved = false; lineSolved = false
                pos2state[p1] = .error
                pos2state[p2] = .error
            }
            let chars = (0..<cols).map { self[r, $0] }.sorted()
            // 3. In one row, each number must appear the same number of times.
            if chars[0] != " " && chars != chars3 {
                isSolved = false; lineSolved = false
                for c in 0..<cols {
                    pos2state[Position(r, c)] = .error
                }
            }
            if lineSolved {
                for c in 0..<cols {
                    pos2state[Position(r, c)] = .complete
                }
            }
        }
        for c in 0..<cols {
            var lineSolved = true
            for r in 0..<rows - 1 {
                let (p1, p2) = (Position(r, c), Position(r + 1, c))
                let (ch1, ch2) = (self[p1], self[p2])
                guard ch1 != " " && ch2 != " " && ch1 == ch2 else {continue}
                // 4. You can't have two identical numbers touching vertically.
                isSolved = false; lineSolved = false
                pos2state[p1] = .error
                pos2state[p2] = .error
            }
            let chars = (0..<rows).map { self[$0, c] }.sorted()
            // 3. In one column, each number must appear the same number of times.
            if chars[0] != " " && chars != chars3 {
                isSolved = false; lineSolved = false
                for r in 0..<rows {
                    pos2state[Position(r, c)] = .error
                }
            }
            if lineSolved {
                for r in 0..<rows {
                    pos2state[Position(r, c)] = .complete
                }
            }
        }
        // 2. Each number can appear only once in each PouringWater.
        for a in game.areas {
            let chars = a.map { self[$0] }.sorted()
            guard chars[0] != " " && chars != chars2 else {continue}
            isSolved = false
            for p in a {
                pos2state[p] = .error
            }
        }
    }
}
