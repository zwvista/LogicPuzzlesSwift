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
    var row2info = [RobotFencesInfo]()
    var col2info = [RobotFencesInfo]()
    var area2info = [RobotFencesInfo]()

    override func copy() -> RobotFencesGameState {
        let v = RobotFencesGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: RobotFencesGameState) -> RobotFencesGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.row2info = row2info
        v.col2info = col2info
        v.area2info = area2info
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
        row2info = Array<RobotFencesInfo>(repeating: RobotFencesInfo(), count: rows)
        col2info = Array<RobotFencesInfo>(repeating: RobotFencesInfo(), count: cols)
        area2info = Array<RobotFencesInfo>(repeating: RobotFencesInfo(), count: game.areas.count)
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
        func f(nums: [Int], info: inout RobotFencesInfo) {
            let count = nums.count
            let nums2 = Set<Int>(nums).sorted()
            let s: HintState = nums2.first! == 0 ? .normal : nums2.count == count && nums2.last! - nums2.first! + 1 == count ? .complete : .error
            info.nums = nums2.filter{$0 != 0}.map{String($0)}.joined()
            info.state = s
            if s != .complete {isSolved = false}
        }
        for r in 0..<rows {
            f(nums: (0..<cols).map({self[r, $0]}), info: &row2info[r])
        }
        for c in 0..<cols {
            f(nums: (0..<rows).map({self[$0, c]}), info: &col2info[c])
        }
        for i in 0..<game.areas.count {
            f(nums: game.areas[i].map({self[$0]}), info: &area2info[i])
        }
    }
}
