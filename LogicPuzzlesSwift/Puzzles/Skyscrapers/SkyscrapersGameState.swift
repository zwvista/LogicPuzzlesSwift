//
//  SkyscrapersGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class SkyscrapersGameState: GridGameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: SkyscrapersGame {
        get {getGame() as! SkyscrapersGame}
        set {setGame(game: newValue)}
    }
    var gameDocument: SkyscrapersDocument { SkyscrapersDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { SkyscrapersDocument.sharedInstance }
    var objArray = [Int]()
    var row2state = [HintState]()
    var col2state = [HintState]()
    
    override func copy() -> SkyscrapersGameState {
        let v = SkyscrapersGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: SkyscrapersGameState) -> SkyscrapersGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.row2state = row2state
        v.col2state = col2state
        return v
    }
    
    required init(game: SkyscrapersGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<Int>(repeating: 0, count: rows * cols)
        row2state = Array<HintState>(repeating: .normal, count: rows * 2)
        col2state = Array<HintState>(repeating: .normal, count: cols * 2)
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
    
    func pos2state(row: Int, col: Int) -> HintState {
        return row == 0 && 1..<cols - 1 ~= col ? col2state[col * 2] :
            row == rows - 1 && 1..<cols - 1 ~= col ? col2state[col * 2 + 1] :
            col == 0 && 1..<rows - 1 ~= row ? row2state[row * 2] :
            col == cols - 1 && 1..<rows - 1 ~= row ? row2state[row * 2 + 1] :
            .normal
    }
    
    func setObject(move: inout SkyscrapersGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) && self[p] != move.obj else {return false}
        self[p] = move.obj
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout SkyscrapersGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) else {return false}
        let o = self[p]
        move.obj = (o + 1) % (game.intMax + 1)
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 1/Skyscrapers

        Summary
        Guess skyscrapers heights, judging from the skyline

        Description
        1. The grid in the center represents a city from above. Each cell contain
           a skyscraper, of different height.
        2. The goal is to guess the height of each Skyscraper.
        3. Each row and column can't have two Skyscrapers of the same height.
        4. The numbers on the boarders tell you how many skyscrapers you see from
           there, keeping mind that a higher skyscraper hides a lower one. 
           Skyscrapers are numbered from 1(lowest) to the grid size(highest).
        5. Each row and column can't have similar Skyscrapers.
    */
    private func updateIsSolved() {
        isSolved = true
        var numss = [[Int]]()
        var nums = [Int]()
        for r in 1..<rows - 1 {
            let (h1, h2) = (self[r, 0], self[r, cols - 1])
            var (n1, n2) = (0, 0)
            var (n11, n21) = (0, 0)
            nums = []
            for c in 1..<cols - 1 {
                let (n12, n22) = (self[r, c], self[r, cols - 1 - c])
                if n11 < n12 {n11 = n12; n1 += 1}
                if n21 < n22 {n21 = n22; n2 += 1}
                guard n12 != 0 else {continue}
                // 2. Each row can't have two Skyscrapers of the same height.
                if nums.contains(n12) {
                    isSolved = false
                } else {
                    nums.append(n12)
                }
            }
            // 4. The numbers on the boarders tell you how many skyscrapers you see from
            // there, keeping mind that a higher skyscraper hides a lower one.
            // Skyscrapers are numbered from 1(lowest) to the grid size(highest).
            let s1: HintState = n1 == 0 ? .normal : n1 == h1 ? .complete : .error
            let s2: HintState = n2 == 0 ? .normal : n2 == h2 ? .complete : .error
            row2state[r * 2] = s1; row2state[r * 2 + 1] = s2
            if s1 != .complete || s2 != .complete {isSolved = false}
            if nums.count != game.intMax {isSolved = false}
            // 5. Each row and column can't have similar Skyscrapers.
            if numss.contains(where: {$0 == nums}) {
                isSolved = false
            } else {
                numss.append(nums)
            }
        }
        for c in 1..<cols - 1 {
            let (h1, h2) = (self[0, c], self[rows - 1, c])
            var (n1, n2) = (0, 0)
            var (n11, n21) = (0, 0)
            nums = []
            for r in 1..<rows - 1 {
                let (n12, n22) = (self[r, c], self[rows - 1 - r, c])
                if n11 < n12 {n11 = n12; n1 += 1}
                if n21 < n22 {n21 = n22; n2 += 1}
                guard n12 != 0 else {continue}
                // 2. Each column can't have two Skyscrapers of the same height.
                if nums.contains(n12) {
                    isSolved = false
                } else {
                    nums.append(n12)
                }
            }
            // 4. The numbers on the boarders tell you how many skyscrapers you see from
            // there, keeping mind that a higher skyscraper hides a lower one.
            // Skyscrapers are numbered from 1(lowest) to the grid size(highest).
            let s1: HintState = n1 == 0 ? .normal : n1 == h1 ? .complete : .error
            let s2: HintState = n2 == 0 ? .normal : n2 == h2 ? .complete : .error
            col2state[c * 2] = s1; col2state[c * 2 + 1] = s2
            if s1 != .complete || s2 != .complete {isSolved = false}
            if nums.count != game.intMax {isSolved = false}
            // 5. Each row and column can't have similar Skyscrapers.
            if numss.contains(where: {$0 == nums}) {
                isSolved = false
            } else {
                numss.append(nums)
            }
        }
    }
}
