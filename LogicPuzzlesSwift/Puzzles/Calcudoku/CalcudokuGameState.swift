//
//  CalcudokuGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class CalcudokuGameState: GridGameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: CalcudokuGame {
        get {getGame() as! CalcudokuGame}
        set {setGame(game: newValue)}
    }
    var gameDocument: CalcudokuDocument { CalcudokuDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { CalcudokuDocument.sharedInstance }
    var objArray = [Int]()
    var row2state = [HintState]()
    var col2state = [HintState]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> CalcudokuGameState {
        let v = CalcudokuGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: CalcudokuGameState) -> CalcudokuGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.row2state = row2state
        v.col2state = col2state
        v.pos2state = pos2state
        return v
    }
    
    required init(game: CalcudokuGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<Int>(repeating: 0, count: rows * cols)
        row2state = Array<HintState>(repeating: .normal, count: rows)
        col2state = Array<HintState>(repeating: .normal, count: cols)
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
    
    func setObject(move: inout CalcudokuGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) && self[p] != move.obj else {return false}
        self[p] = move.obj
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout CalcudokuGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) else {return false}
        let o = self[p]
        move.obj = (o + 1) % (cols + 1)
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 4/Calcudoku

        Summary
        Mathematical Sudoku

        Description
        1. Write numbers ranging from 1 to board size respecting the calculation
           hint.
        2. The tiny numbers and math signs in the corner of an area give you the
           hint about what's happening inside that area.
        3. For example a '3+' means that the sum of the numbers inside that area
           equals 3. In that case you would have to write the numbers 1 and 2
           there.
        4. Another example: '12*' means that the multiplication of the numbers
           in that area gives 12, so it could be 3 and 4 or even 3, 4 and 1,
           depending on the area size.
        5. Even where the order of the operands matter (in subtraction and division)
           they can appear in any order inside the area (ie.e. 2/ could be done
           with 4 and 2 or 2 and 4.
        6. All the numbers appear just one time in each row and column, but they
           could be repeated in non-straight areas, like the L-shaped one.
    */
    private func updateIsSolved() {
        isSolved = true
        func f(nums: [Int], s: inout HintState) {
            let nums2 = Set<Int>(nums).sorted()
            // 1. Write numbers ranging from 1 to board size.
            s = nums2.first! == 0 ? .normal : nums2.count == nums.count ? .complete : .error
            if s != .complete {isSolved = false}
        }
        // 6. All the numbers appear just one time in each row.
        for r in 0..<rows {
            f(nums: (0..<cols).map{self[r, $0]}, s: &row2state[r])
        }
        // 6. All the numbers appear just one time in each column.
        for c in 0..<cols {
            f(nums: (0..<rows).map{self[$0, c]}, s: &col2state[c])
        }
        for (p, h) in game.pos2hint {
            let nums = game.areas[game.pos2area[p]!].map{self[$0]}
            func g() -> HintState {
                if nums.contains(0) {return .normal}
                let n = h.result
                switch h.op {
                // 2. The tiny numbers and math signs in the corner of an area give you the
                // hint about what's happening inside that area.
                case "+":
                    return nums.reduce(0, +) == n ? .complete : .error
                case "-":
                    let (n1, n2) = (nums[0], nums[1])
                    return n1 - n2 == n || n2 - n1 == n ? .complete : .error
                case "*":
                    return nums.reduce(1, *) == n ? .complete : .error
                case "/":
                    let (n1, n2) = (nums[0], nums[1])
                    return n1 / n2 * n2 == n * n2 || n2 / n1 * n1 == n * n1 ? .complete : .error
                default:
                    return .normal
                }
            }
            let s = g()
            pos2state[p] = s
            if s != .complete {isSolved = false}
        }
    }
}
