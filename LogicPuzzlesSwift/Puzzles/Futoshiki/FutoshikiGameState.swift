//
//  FutoshikiGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class FutoshikiGameState: GridGameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: FutoshikiGame {
        get { getGame() as! FutoshikiGame }
        set { setGame(game: newValue) }
    }
    var gameDocument: FutoshikiDocument { FutoshikiDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { FutoshikiDocument.sharedInstance }
    var objArray = [Character]()
    var row2state = [HintState]()
    var col2state = [HintState]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> FutoshikiGameState {
        let v = FutoshikiGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: FutoshikiGameState) -> FutoshikiGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.row2state = row2state
        v.col2state = col2state
        v.pos2state = pos2state
        return v
    }
    
    required init(game: FutoshikiGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
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
    
    func setObject(move: inout FutoshikiGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) && p.row % 2 == 0 && p.col % 2 == 0 && game[p] == " " && self[p] != move.obj else { return false }
        self[p] = move.obj
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout FutoshikiGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) && p.row % 2 == 0 && p.col % 2 == 0 && game[p] == " " else { return false }
        let o = self[p]
        move.obj = o == " " ? "1" : o == succ(ch: "1", offset: rows / 2) ? " " : succ(ch: o)
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 2/Futoshiki

        Summary
        Fill the rows and columns with numbers, respecting the relations

        Description
        1. In a manner similar to Sudoku, you have to put in each row and column
           numbers ranging from 1 to N, where N is the puzzle board size.
        2. The hints you have are the 'less than'/'greater than' signs between tiles.
        3. Remember you can't repeat the same number in a row or column.

        Variation
        4. Some boards, instead of having less/greater signs, have just a line
           separating the tiles.
        5. That separator hints at two tiles with consecutive numbers, i.e. 1-2
           or 3-4..
        6. Please note that in this variation consecutive numbers MUST have a
           line separating the tiles. Otherwise they're not consecutive.
        7. This Variation is a taste of a similar game: 'Consecutives'.
    */
    private func updateIsSolved() {
        isSolved = true
        func f(nums: [Character], s: inout HintState) {
            let nums2 = Set<Character>(nums).sorted()
            // 1. You have to put in each row and column
            // numbers ranging from 1 to N, where N is the puzzle board size.
            s = nums2.first! == " " ? .normal : nums2.count == nums.count ? .complete : .error
            if s != .complete { isSolved = false }
        }
        // 3. Remember you can't repeat the same number in a row.
        for r in stride(from: 0, to: rows, by: 2) {
            f(nums: stride(from: 0, to: cols, by: 2).map { self[r, $0] } , s: &row2state[r])
        }
        // 3. Remember you can't repeat the same number in a column.
        for c in stride(from: 0, to: cols, by: 2) {
            f(nums: stride(from: 0, to: rows, by: 2).map { self[$0, c] } , s: &col2state[c])
        }
        for (p, h) in game.pos2hint {
            let (r, c) = (p.row, p.col)
            let (ch1, ch2) = r % 2 == 0 ? (self[r, c - 1], self[r, c + 1]) : (self[r - 1, c], self[r + 1, c])
            func g() -> HintState {
                if ch1 == " " || ch2 == " " { return .normal }
                let (n1, n2) = (ch1.toInt!, ch2.toInt!)
                switch h {
                // 2. The hints you have are the 'less than'/'greater than' signs between tiles.
                case "^", "<":
                    return n1 < n2 ? .complete : .error
                case "v", ">":
                    return n1 > n2 ? .complete : .error
                default:
                    return .normal
                }
            }
            let s = g()
            pos2state[p] = s
            if s != .complete { isSolved = false }
        }
    }
}
