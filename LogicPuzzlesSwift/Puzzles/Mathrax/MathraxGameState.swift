//
//  MathraxGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class MathraxGameState: GridGameState<MathraxGame, MathraxDocument> {
    override var gameDocument: MathraxDocument { MathraxDocument.sharedInstance }
    var objArray = [Int]()
    var row2state = [HintState]()
    var col2state = [HintState]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> MathraxGameState {
        let v = MathraxGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: MathraxGameState) -> MathraxGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.row2state = row2state
        v.col2state = col2state
        v.pos2state = pos2state
        return v
    }
    
    required init(game: MathraxGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        row2state = Array<HintState>(repeating: .normal, count: rows)
        col2state = Array<HintState>(repeating: .normal, count: cols)
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
    
    func setObject(move: inout MathraxGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) && game[p] == 0 && self[p] != move.obj else { return false }
        self[p] = move.obj
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout MathraxGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) && game[p] == 0 else { return false }
        let o = self[p]
        move.obj = (o + 1) % (cols + 1)
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 6/Mathrax

        Summary
        Diagonal Math Wiz

        Description
        1. The goal is to input numbers 1 to N, where N is the board size, following
           the hints in the intersections.
        2. A number must appear once for every row and column.
        3. The tiny numbers and sign in the intersections tell you the result of
           the operation between the two opposite diagonal tiles. This is valid
           for both pairs of numbers surrounding the hint.
        4. In some puzzles, there will be 'E' or 'O' as hint. This means that all
           four tiles are either (E)ven or (O)dd numbers.
    */
    private func updateIsSolved() {
        isSolved = true
        func f(nums: [Int], s: inout HintState) {
            let nums2 = Set<Int>(nums).sorted()
            // 1. The goal is to input numbers 1 to N, where N is the board size.
            s = nums2.first! == 0 ? .normal : nums2.count == nums.count ? .complete : .error
            if s != .complete { isSolved = false }
        }
        // 2. A number must appear once for every row.
        for r in 0..<rows {
            f(nums: (0..<cols).map { self[r, $0] } , s: &row2state[r])
        }
        // 2. A number must appear once for every column.
        for c in 0..<cols {
            f(nums: (0..<rows).map { self[$0, c] } , s: &col2state[c])
        }
        for (p, h) in game.pos2hint {
            func g(n1: Int, n2: Int) -> HintState {
                if n1 == 0 || n2 == 0 { return .normal }
                let n = h.result
                switch h.op {
                // 3. The tiny numbers and sign in the intersections tell you the result of
                // the operation between the two opposite diagonal tiles.
                case "+":
                    return n1 + n2 == n ? .complete : .error
                case "-":
                    return n1 - n2 == n || n2 - n1 == n ? .complete : .error
                case "*":
                    return n1 * n2 == n ? .complete : .error
                case "/":
                    return n1 / n2 * n2 == n * n2 || n2 / n1 * n1 == n * n1 ? .complete : .error
                // 4. In some puzzles, there will be 'E' or 'O' as hint. This means that all
                // four tiles are either (E)ven or (O)dd numbers.
                case "O":
                    return n1 % 2 == 1 && n2 % 2 == 1 ? .complete : .error
                case "E":
                    return n1 % 2 == 0 && n2 % 2 == 0 ? .complete : .error
                default:
                    return .normal
                }
            }
            let nums = MathraxGame.offset2.map { self[p + $0] }
            // 3. This is valid for both pairs of numbers surrounding the hint.
            let (s1, s2) = (g(n1: nums[0], n2: nums[1]), g(n1: nums[2], n2: nums[3]))
            let s: HintState = s1 == .error || s2 == .error ? .error :
                s1 == .complete && s2 == .complete ? .complete : .normal
            pos2state[p] = s
            if s != .complete { isSolved = false }
        }
    }
}
