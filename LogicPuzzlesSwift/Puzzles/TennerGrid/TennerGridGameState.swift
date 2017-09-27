//
//  TennerGridGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class TennerGridGameState: GridGameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: TennerGridGame {
        get {return getGame() as! TennerGridGame}
        set {setGame(game: newValue)}
    }
    var gameDocument: TennerGridDocument { return TennerGridDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return TennerGridDocument.sharedInstance }
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
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> Int {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }

    func setObject(move: inout TennerGridGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) && game[p] == -1 && self[p] != move.obj else {return false}
        self[p] = move.obj
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout TennerGridGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) && game[p] == -1 else {return false}
        let o = self[p]
        move.obj = (o + 1) % 10
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
        for c in 0..<cols {
            let h = self[rows - 1, c]
            var n = 0, isDirty = false, allFixed = true
            for r in 0..<rows - 1 {
                let (o1, o2) = (game[r, c], self[r, c])
                if o1 == -1 {
                    allFixed = false
                    if o2 == -1 {
                        isSolved = false
                    } else {
                        isDirty = true
                    }
                }
                n += o2 == -1 ? 0 : o2
            }
            let s: HintState = !isDirty && !allFixed ? .normal : n == h ? .complete : .error
            pos2state[Position(rows - 1, c)] = s
            if s != .complete {isSolved = false}
        }
        for r in 0..<rows - 1 {
            var nums = Set<Int>()
            var rowState: HintState = .complete
            for c in 0..<cols {
                let (o1, o2) = (game[r, c], self[r, c])
                if o1 == -1 && o2 == -1 {rowState = .normal}
                if o2 != -1 {nums.insert(o2)}
            }
            if nums.count != cols {
                isSolved = false
                if rowState == .complete {rowState = .error}
            }
            for c in 0..<cols {
                let p = Position(r, c)
                let (o1, o2) = (game[p], self[p])
                if o1 == -1 && o2 != -1 {
                    pos2state[p] = rowState
                }
            }
        }
    }
}
