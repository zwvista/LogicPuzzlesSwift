//
//  NoughtsAndCrossesGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class NoughtsAndCrossesGameState: GridGameState<NoughtsAndCrossesGame, NoughtsAndCrossesDocument, NoughtsAndCrossesGameMove> {
    override var gameDocument: NoughtsAndCrossesDocument { NoughtsAndCrossesDocument.sharedInstance }
    var objArray = [Character]()
    var row2state = [HintState]()
    var col2state = [HintState]()
    var pos2state = [Position: HintState]()

    override func copy() -> NoughtsAndCrossesGameState {
        let v = NoughtsAndCrossesGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: NoughtsAndCrossesGameState) -> NoughtsAndCrossesGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.row2state = row2state
        v.col2state = col2state
        v.pos2state = pos2state
        return v
    }
    
    required init(game: NoughtsAndCrossesGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<Character>(repeating: " ", count: rows * cols)
        for r in 0..<rows {
            for c in 0..<cols {
                self[r, c] = game[r, c]
            }
        }
        row2state = Array<HintState>(repeating: .normal, count: rows)
        col2state = Array<HintState>(repeating: .normal, count: cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> Character {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> Character {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }

    override func setObject(move: inout NoughtsAndCrossesGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) && game[p] == " " && self[p] != move.obj else { return false }
        self[p] = move.obj
        updateIsSolved()
        return true
    }
    
    override func switchObject(move: inout NoughtsAndCrossesGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) && game[p] == " " else { return false }
        let o = self[p]
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        move.obj =
            o == " " ? markerOption == .markerFirst ? "." : "1" :
            o == "." ? markerOption == .markerFirst ? "1" : " " :
            o == game.chMax ? markerOption == .markerLast ? "." : " " :
            succ(ch: o)
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 16/Noughts & Crosses

        Summary
        Spot the Number

        Description
        1. Place all numbers from 1 to N on each row and column - just once,
           without repeating.
        2. In other words, all numbers must appear just once on each row and column.
        3. A circle marks where a number must go.
        4. A cross marks where no number can go.
        5. All other cells can contain a number or be empty.
    */
    private func updateIsSolved() {
        isSolved = true
        func f(nums: [Character], s: inout HintState) {
            var nums = nums
            // 4. A cross marks where no number can go.
            // 5. All other cells can contain a number or be empty.
            nums.removeAll([" ", ".", "X"])
            // 2. All numbers must appear just once.
            s = nums.count == game.chMax.toInt! && nums.count == Set<Character>(nums).count ? .complete : .error
            if s != .complete { isSolved = false }
        }
        // 2. All numbers must appear just once on each row.
        for r in 0..<rows {
            f(nums: (0..<cols).map { self[r, $0] } , s: &row2state[r])
        }
        // 2. All numbers must appear just once on each column.
        for c in 0..<cols {
            f(nums: (0..<rows).map { self[$0, c] } , s: &col2state[c])
        }
        // 3. A circle marks where a number must go.
        for p in game.noughts {
            let ch = self[p]
            pos2state[p] = ch == " " || ch == "." ? .normal : .complete
            if pos2state[p] != .complete { isSolved = false }
        }
    }
}
