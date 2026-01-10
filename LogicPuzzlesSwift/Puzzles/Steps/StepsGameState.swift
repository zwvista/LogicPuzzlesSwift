//
//  StepsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class StepsGameState: GridGameState<StepsGameMove> {
    var game: StepsGame {
        get { getGame() as! StepsGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { StepsDocument.sharedInstance }
    var objArray = [Int]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> StepsGameState {
        let v = StepsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: StepsGameState) -> StepsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: StepsGame, isCopy: Bool = false) {
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
    
    override func setObject(move: inout StepsGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == StepsGame.PUZ_EMPTY && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout StepsGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == StepsGame.PUZ_EMPTY else { return .invalid }
        let o = self[p]
        let n = game.areas[game.pos2area[p]!].count
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        move.obj =
            o == StepsGame.PUZ_EMPTY ? markerOption == .markerFirst ? StepsGame.PUZ_MARKER : n :
            o == n ? markerOption == .markerLast ? StepsGame.PUZ_MARKER : StepsGame.PUZ_EMPTY :
            o == StepsGame.PUZ_MARKER ? markerOption == .markerFirst ? n : StepsGame.PUZ_EMPTY :
            o
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 6/Steps

        Summary
        Go up or down

        Description
        1. Each area has a single number in it, which is equal to the area size.
        2. Its position should be such that, by moving horizontally and vertically,
           the distance to another number should be the difference between the two
           numbers.
        3. Or in other words: The number of empty squares between any pair of numbers
           in the same row or column, must equal the difference between those numbers.
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                pos2state[p] = .normal
                if self[p] == StepsGame.PUZ_FORBIDDEN {
                    self[p] = StepsGame.PUZ_EMPTY
                }
            }
        }
        for area in game.areas {
            var rng = [Position]()
            for p in area {
                guard self[p] != StepsGame.PUZ_EMPTY else {continue}
                rng.append(p)
            }
            // 1. Each area has a single number in it, which is equal to the area size.
            if !(rng.count == 1 && self[rng[0]] == area.count) {
                isSolved = false
                for p in rng { pos2state[p] = .error }
            }
            guard allowedObjectsOnly && !rng.isEmpty else {continue}
            for p in area where !rng.contains(p) {
                self[p] = StepsGame.PUZ_FORBIDDEN
            }
        }
        // 2. Its position should be such that, by moving horizontally and vertically,
        //    the distance to another number should be the difference between the two
        //    numbers.
        // 3. Or in other words: The number of empty squares between any pair of numbers
        //    in the same row or column, must equal the difference between those numbers.
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let n = self[p]
                guard n > 0 else {continue}
                if pos2state[p] != .error { pos2state[p] = .complete }
                next: for i in [1, 2] {
                    let os = StepsGame.offset[i]
                    var p2 = p + os, steps = 0
                    while true {
                        guard isValid(p: p2) else {continue next}
                        guard self[p2] <= 0 else {break}
                        p2 += os; steps += 1
                    }
                    let s: HintState = abs(self[p2] - n) == steps ? .complete : .error
                    if s != .complete { isSolved = false }
                    if pos2state[p] == .complete { pos2state[p] = s }
                    if pos2state[p2] == .complete { pos2state[p2] = s }
                }
            }
        }
    }
}
