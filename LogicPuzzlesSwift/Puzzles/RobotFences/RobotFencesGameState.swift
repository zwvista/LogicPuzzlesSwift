//
//  RobotFencesGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class RobotFencesGameState: GridGameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: RobotFencesGame {
        get {getGame() as! RobotFencesGame}
        set {setGame(game: newValue)}
    }
    var gameDocument: RobotFencesDocument { RobotFencesDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { RobotFencesDocument.sharedInstance }
    var objArray = [Int]()
    var row2state = [HintState]()
    var col2state = [HintState]()
    var area2state = [HintState]()

    override func copy() -> RobotFencesGameState {
        let v = RobotFencesGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: RobotFencesGameState) -> RobotFencesGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.row2state = row2state
        v.col2state = col2state
        v.area2state = area2state
        return v
    }
    
    required init(game: RobotFencesGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<Int>(repeating: 0, count: rows * cols)
        for r in 0..<rows {
            for c in 0..<cols {
                self[r, c] = game[r, c]
            }
        }
        row2state = Array<HintState>(repeating: .normal, count: rows)
        col2state = Array<HintState>(repeating: .normal, count: cols)
        area2state = Array<HintState>(repeating: .normal, count: game.areas.count)
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

    func setObject(move: inout RobotFencesGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) && game[p] == 0 && self[p] != move.obj else {return false}
        self[p] = move.obj
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout RobotFencesGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) && game[p] == 0 else {return false}
        let o = self[p]
        move.obj = (o + 1) % (cols + 1)
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 13/Robot Fences

        Summary
        BZZZZliip ...cows?

        Description
        1. A bit like Robot Crosswords, you need to fill each region with a
           randomly ordered sequence of numbers.
        2. Numbers can only be in range 1 to N where N is the board size.
        3. No same number can appear in the same row or column.
    */
    private func updateIsSolved() {
        isSolved = true
        func f(nums: [Int], s: inout HintState) {
            let nums2 = Set<Int>(nums).sorted()
            // 2. Numbers can only be in range 1 to N where N is the board size.
            s = nums2.first! == 0 ? .normal : nums2.count == nums.count ? .complete : .error
            if s != .complete {isSolved = false}
        }
        // 3. No same number can appear in the same row.
        for r in 0..<rows {
            f(nums: (0..<cols).map{self[r, $0]}, s: &row2state[r])
        }
        // 3. No same number can appear in the same column.
        for c in 0..<cols {
            f(nums: (0..<rows).map{self[$0, c]}, s: &col2state[c])
        }
        // 1. You need to fill each region with a randomly ordered sequence of numbers.
        for i in 0..<game.areas.count {
            f(nums: game.areas[i].map{self[$0]}, s: &area2state[i])
        }
    }
}
