//
//  TennerGridGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class TennerGridGameState: GridGameState<TennerGridGameMove> {
    var game: TennerGridGame {
        get { getGame() as! TennerGridGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { TennerGridDocument.sharedInstance }
    var objArray = [Int]()
    var pos2state = [Position: HintState]()

    override func copy() -> TennerGridGameState {
        let v = TennerGridGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: TennerGridGameState) -> TennerGridGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: TennerGridGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<Int>(repeating: -1, count: rows * cols)
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

    override func setObject(move: inout TennerGridGameMove) -> GameChangeType {
        let p = move.p
        guard isValid(p: p) && game[p] == -1 && self[p] != move.obj else { return .none }
        self[p] = move.obj
        updateIsSolved()
        return .level
    }
    
    override func switchObject(move: inout TennerGridGameMove) -> GameChangeType {
        let p = move.p
        guard isValid(p: p) && game[p] == -1 else { return .none }
        let o = self[p]
        move.obj = o == 9 ? -1 : o + 1
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 7/TennerGrid

        Summary
        Counting up to 10

        Description
        1. You goal is to enter every digit, from 0 to 9, in each row of the Grid.
        2. The number on the bottom row gives you the sum for that column.
        3. Digit can repeat on the same column, however digits in contiguous tiles
           must be different, even diagonally. Obviously digits can't repeat on
           the same row.
    */
    private func updateIsSolved() {
        isSolved = true
        for r in 0..<rows - 1 {
            // https://stackoverflow.com/questions/31220002/how-to-group-by-the-elements-of-an-array-in-swift
            let cs = Dictionary(grouping: 0..<cols, by: { self[r, $0] }).filter { $0.0 != -1 && $0.1.count > 1 }.flatMap { $0.1 }
            // 3. Obviously digits can't repeat on the same row.
            if !cs.isEmpty { isSolved = false }
            for c in 0..<cols - 1 {
                pos2state[Position(r, c)] = cs.contains(c) ? .error : .normal
            }
        }
        for c in 0..<cols {
            let h = self[rows - 1, c]
            var n = 0, isDirty = false, allFixed = true
            for r in 0..<rows - 1 {
                let p = Position(r, c)
                let (o1, o2) = (game[p], self[p])
                if o1 == -1 {
                    allFixed = false
                    if o2 == -1 {
                        isSolved = false
                    } else {
                        isDirty = true
                    }
                }
                n += o2 == -1 ? 0 : o2
                // 3. Digit can repeat on the same column, however digits in contiguous tiles
                // must be different, even diagonally.
                if r < rows - 2 {
                    let rng = TennerGridGame.offset.map { p + $0 }.filter { p2 in isValid(p: p2) && o2 == self[p2] }
                    if !rng.isEmpty {
                        isSolved = false
                        pos2state[p] = .error
                        for p2 in rng {
                            pos2state[p2] = .error
                        }
                    }
                }
            }
            // 2. The number on the bottom row gives you the sum for that column.
            let s: HintState = !isDirty && !allFixed ? .normal : n == h ? .complete : .error
            pos2state[Position(rows - 1, c)] = s
            if s != .complete { isSolved = false }
        }
    }
}
