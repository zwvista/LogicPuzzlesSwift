//
//  NumberCrossingGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class NumberCrossingGameState: GridGameState<NumberCrossingGameMove> {
    var game: NumberCrossingGame {
        get { getGame() as! NumberCrossingGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { NumberCrossingDocument.sharedInstance }
    var objArray = [Int]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> NumberCrossingGameState {
        let v = NumberCrossingGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: NumberCrossingGameState) -> NumberCrossingGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: NumberCrossingGame, isCopy: Bool = false) {
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
    
    override func setObject(move: inout NumberCrossingGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && self[p] != NumberCrossingGame.PUZ_FORBIDDEN && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout NumberCrossingGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && self[p] != NumberCrossingGame.PUZ_FORBIDDEN else { return .invalid }
        let o = self[p]
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        move.obj =
            o == NumberCrossingGame.PUZ_UNKNOWN ? markerOption == .markerFirst ? NumberCrossingGame.PUZ_MARKER : 1 :
            o == NumberCrossingGame.PUZ_MARKER ? markerOption == .markerFirst ? 1 :  NumberCrossingGame.PUZ_UNKNOWN :
            o == 9 ? markerOption == .markerLast ? NumberCrossingGame.PUZ_MARKER : NumberCrossingGame.PUZ_UNKNOWN :
            o + 1
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games/Puzzle Set 17/Number Crossing

        Summary
        Digital Crosswords

        Description
        1. Find the numbers in the board.
        2. Numbers cannot touch each other, not even diagonally.
        3. On the top and left of the grid, you're given how many numbers are in that
           column or row.
        4. On the bottom and right of the grid, you're given the sum of the numbers
           on that column or row.
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        for r in 1..<rows - 1 {
            let p1 = Position(r, 0), p2 = Position(r, cols - 1)
            let (h1, h2) = (self[p1], self[p2])
            var (n1, n2) = (0, 0)
            for c in 1..<cols - 1 {
                let p = Position(r, c)
                let o = self[p]
                guard o > 0 else {continue}
                n1 += 1; n2 += o
                pos2state[p] = .normal
                // 2. Numbers cannot touch each other, not even diagonally.
                for os in NumberCrossingGame.offset {
                    let p2 = p + os
                    guard isValid(p: p2) else {continue}
                    let o2 = self[p2]
                    if o2 > 0 {
                        pos2state[p] = .error
                        pos2state[p2] = .error
                        isSolved = false
                    } else if allowedObjectsOnly && o2 == NumberCrossingGame.PUZ_UNKNOWN {
                        self[p2] = NumberCrossingGame.PUZ_FORBIDDEN
                    }
                }
            }
            // 3. On the top and left of the grid, you're given how many numbers are in that
            //    column or row.
            // 4. On the bottom and right of the grid, you're given the sum of the numbers
            //    on that column or row.
            let s1: HintState = n1 < h1 ? .normal : n1 == h1 ? .complete : .error
            let s2: HintState = n2 < h2 ? .normal : n2 == h2 ? .complete : .error
            pos2state[p1] = s1; pos2state[p2] = s2
            if s1 != .complete || s2 != .complete { isSolved = false }
            if allowedObjectsOnly && (s1 != .normal || s2 != .normal) {
                for c in 1..<cols - 1 {
                    if self[r, c] == NumberCrossingGame.PUZ_UNKNOWN {
                        self[r, c] = NumberCrossingGame.PUZ_FORBIDDEN
                    }
                }
            }
        }
        for c in 1..<cols - 1 {
            let p1 = Position(0, c), p2 = Position(rows - 1, c)
            let (h1, h2) = (self[p1], self[p2])
            var (n1, n2) = (0, 0)
            for r in 1..<rows - 1 {
                let p = Position(r, c)
                let o = self[p]
                guard o > 0 else {continue}
                n1 += 1; n2 += o
                pos2state[p] = .normal
                // 2. Numbers cannot touch each other, not even diagonally.
                for os in NumberCrossingGame.offset {
                    let p2 = p + os
                    guard isValid(p: p2) else {continue}
                    let o2 = self[p2]
                    if o2 > 0 {
                        pos2state[p] = .error
                        pos2state[p2] = .error
                        isSolved = false
                    } else if allowedObjectsOnly && o2 == NumberCrossingGame.PUZ_UNKNOWN {
                        self[p2] = NumberCrossingGame.PUZ_FORBIDDEN
                    }
                }
            }
            // 3. On the top and left of the grid, you're given how many numbers are in that
            //    column or row.
            // 4. On the bottom and right of the grid, you're given the sum of the numbers
            //    on that column or row.
            let s1: HintState = n1 < h1 ? .normal : n1 == h1 ? .complete : .error
            let s2: HintState = n2 < h2 ? .normal : n2 == h2 ? .complete : .error
            pos2state[p1] = s1; pos2state[p2] = s2
            if s1 != .complete || s2 != .complete { isSolved = false }
            if allowedObjectsOnly && (s1 != .normal || s2 != .normal) {
                for r in 1..<rows - 1 {
                    if self[r, c] == NumberCrossingGame.PUZ_UNKNOWN {
                        self[r, c] = NumberCrossingGame.PUZ_FORBIDDEN
                    }
                }
            }
        }
    }
}
