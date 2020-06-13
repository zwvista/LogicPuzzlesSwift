//
//  TheOddBrickGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class TheOddBrickGameState: GridGameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: TheOddBrickGame {
        get { getGame() as! TheOddBrickGame }
        set { setGame(game: newValue) }
    }
    var gameDocument: TheOddBrickDocument { TheOddBrickDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { TheOddBrickDocument.sharedInstance }
    var objArray = [Int]()
    var row2state = [HintState]()
    var col2state = [HintState]()
    var area2state = [HintState]()

    override func copy() -> TheOddBrickGameState {
        let v = TheOddBrickGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: TheOddBrickGameState) -> TheOddBrickGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.row2state = row2state
        v.col2state = col2state
        v.area2state = area2state
        return v
    }
    
    required init(game: TheOddBrickGame, isCopy: Bool = false) {
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
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> Int {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }

    func setObject(move: inout TheOddBrickGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) && game[p] == 0 && self[p] != move.obj else { return false }
        self[p] = move.obj
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout TheOddBrickGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) && game[p] == 0 else { return false }
        let o = self[p]
        move.obj = (o + 1) % (cols + 1)
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 14/The Odd Brick

        Summary
        Even Bricks are strange, sometimes

        Description
        1. On the board there is a wall, made of 2*1 and 1*1 bricks.
        2. Each 2*1 brick contains and odd and an even number, while 1*1 bricks
           can contain any number.
        3. Each row and column contains numbers 1 to N, where N is the side of
           the board.
    */
    private func updateIsSolved() {
        isSolved = true
        func f(nums: [Int], s: inout HintState) {
            let nums2 = Set<Int>(nums).sorted()
            // 3. Each row and column contains numbers 1 to N, where N is the side of
            // the board.
            s = nums2.first! == 0 ? .normal : nums2.count == nums.count ? .complete : .error
            if s != .complete { isSolved = false }
        }
        for r in 0..<rows {
            f(nums: (0..<cols).map { self[r, $0] } , s: &row2state[r])
        }
        for c in 0..<cols {
            f(nums: (0..<rows).map { self[$0, c] } , s: &col2state[c])
        }
        for i in 0..<game.areas.count {
            let nums = game.areas[i].map { self[$0] }
            // 2. Each 2*1 brick contains and odd and an even number, while 1*1 bricks
            // can contain any number.
            area2state[i] = nums.contains(0) ? .normal : nums.count == 1 || nums[0] % 2 == 0 && nums[1] % 2 == 1 || nums[0] % 2 == 1 && nums[1] % 2 == 0 ? .complete : .error
            if area2state[i] != .complete { isSolved = false }
        }
    }
}
