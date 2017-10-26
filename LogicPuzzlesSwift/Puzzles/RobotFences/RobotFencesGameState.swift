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
        get {return getGame() as! RobotFencesGame}
        set {setGame(game: newValue)}
    }
    var gameDocument: RobotFencesDocument { return RobotFencesDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return RobotFencesDocument.sharedInstance }
    var objArray = [Int]()
    var pos2horzState = [Position: HintState]()
    var pos2vertState = [Position: HintState]()

    override func copy() -> RobotFencesGameState {
        let v = RobotFencesGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: RobotFencesGameState) -> RobotFencesGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2horzState = pos2horzState
        v.pos2vertState = pos2vertState
        return v
    }
    
    required init(game: RobotFencesGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<Int>(repeating: 0, count: rows * cols)
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
        iOS Game: Logic Games/Puzzle Set 13/RobotCrosswords

        Summary
        BZZZZliip 4 across?

        Description
        1. In a possible crossword for Robots, letters are substituted with digits.
        2. Each 'word' is formed by an uninterrupted sequence of numbers (i.e.
           2-3-4-5), but in any order (i.e. 3-4-2-5).
    */
    private func updateIsSolved() {
        isSolved = true
        func isUninterrupted(nums: Set<Int>) -> Bool {
            let nums2 = nums.sorted()
            return [Int](0..<nums2.count - 1).testAll{i in nums2[i + 1] - nums2[i] == 1}
        }
        var nums = Set<Int>()
        next_r: for r in 0..<rows {
            nums.removeAll()
            for c in 0..<cols {
                let n = self[r, c]
                if n == 0 {isSolved = false; continue next_r}
                nums.insert(n)
            }
            if nums.count != cols || !isUninterrupted(nums: nums) {isSolved = false}
        }
        next_c: for c in 0..<cols {
            nums.removeAll()
            for r in 0..<rows {
                let n = self[r, c]
                if n == 0 {isSolved = false; continue next_c}
                nums.insert(self[r, c])
            }
            if nums.count != rows || !isUninterrupted(nums: nums) {isSolved = false}
        }
        next_a: for a in game.areas {
            nums.removeAll()
            for p in a {
                let n = self[p]
                if n == 0 {isSolved = false; continue next_a}
                nums.insert(n)
            }
            if nums.count != a.count || !isUninterrupted(nums: nums) {isSolved = false}
        }
    }
}
