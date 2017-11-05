//
//  MathraxGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class MathraxGameState: GridGameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: MathraxGame {
        get {return getGame() as! MathraxGame}
        set {setGame(game: newValue)}
    }
    var gameDocument: MathraxDocument { return MathraxDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return MathraxDocument.sharedInstance }
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
    
    func setObject(move: inout MathraxGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) && game[p] == 0 && self[p] != move.obj else {return false}
        self[p] = move.obj
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout MathraxGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) && game[p] == 0 else {return false}
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
            let count = nums.count
            let nums2 = Set<Int>(nums).sorted()
            s = nums2.first! == 0 ? .normal : nums2.count == count && nums2.last! - nums2.first! + 1 == count ? .complete : .error
            if s != .complete {isSolved = false}
        }
        for r in 0..<rows {
            f(nums: (0..<cols).map({self[r, $0]}), s: &row2state[r])
        }
        for c in 0..<cols {
            f(nums: (0..<rows).map({self[$0, c]}), s: &col2state[c])
        }
    }
}
