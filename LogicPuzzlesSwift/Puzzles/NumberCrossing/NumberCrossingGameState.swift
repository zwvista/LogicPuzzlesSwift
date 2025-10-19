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
    var row2state = [HintState]()
    var col2state = [HintState]()
    
    override func copy() -> NumberCrossingGameState {
        let v = NumberCrossingGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: NumberCrossingGameState) -> NumberCrossingGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.row2state = row2state
        v.col2state = col2state
        return v
    }
    
    required init(game: NumberCrossingGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<Int>(repeating: 0, count: rows * cols)
        row2state = Array<HintState>(repeating: .normal, count: rows * 2)
        col2state = Array<HintState>(repeating: .normal, count: cols * 2)
        for r in 0..<rows {
            for c in 0..<cols {
                self[r, c] = game[r, c]
            }
        }
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
    
    func pos2state(row: Int, col: Int) -> HintState {
        row == 0 && 1..<cols - 1 ~= col ? col2state[col * 2] :
            row == rows - 1 && 1..<cols - 1 ~= col ? col2state[col * 2 + 1] :
            col == 0 && 1..<rows - 1 ~= row ? row2state[row * 2] :
            col == cols - 1 && 1..<rows - 1 ~= row ? row2state[row * 2 + 1] :
            .normal
    }
    
    override func setObject(move: inout NumberCrossingGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout NumberCrossingGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) else { return .invalid }
        let o = self[p]
        move.obj =
            o == NumberCrossingGame.PUZ_UNKNOWN ? 1 :
            o == game.intMax ? NumberCrossingGame.PUZ_UNKNOWN :
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
        isSolved = true
        for r in 1..<rows - 1 {
            let (h1, h2) = (self[r, 0], self[r, cols - 1])
            var (n1, n2) = (0, 0)
            for c in 1..<cols - 1 {
                let o = self[r, c]
                guard o != NumberCrossingGame.PUZ_UNKNOWN else { continue }
                n1 += 1; n2 += o
            }
            // 3. On the top and left of the grid, you're given how many numbers are in that
            //    column or row.
            // 4. On the bottom and right of the grid, you're given the sum of the numbers
            //    on that column or row.
            let s1: HintState = n1 < h1 ? .normal : n1 == h1 ? .complete : .error
            let s2: HintState = n2 < h2 ? .normal : n2 == h2 ? .complete : .error
            row2state[r * 2] = s1; row2state[r * 2 + 1] = s2
            if s1 != .complete || s2 != .complete { isSolved = false }
        }
        for c in 1..<cols - 1 {
            let (h1, h2) = (self[0, c], self[rows - 1, c])
            var (n1, n2) = (0, 0)
            for r in 1..<rows - 1 {
                let o = self[r, c]
                guard o != NumberCrossingGame.PUZ_UNKNOWN else { continue }
                n1 += 1; n2 += o
            }
            // 3. On the top and left of the grid, you're given how many numbers are in that
            //    column or row.
            // 4. On the bottom and right of the grid, you're given the sum of the numbers
            //    on that column or row.
            let s1: HintState = n1 < h1 ? .normal : n1 == h1 ? .complete : .error
            let s2: HintState = n2 < h2 ? .normal : n2 == h2 ? .complete : .error
            col2state[c * 2] = s1; col2state[c * 2 + 1] = s2
            if s1 != .complete || s2 != .complete { isSolved = false }
        }
    }
}
