//
//  ArrowsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class ArrowsGameState: GridGameState<ArrowsGameMove> {
    var game: ArrowsGame {
        get { getGame() as! ArrowsGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { ArrowsDocument.sharedInstance }
    var objArray = [Int]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> ArrowsGameState {
        let v = ArrowsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: ArrowsGameState) -> ArrowsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: ArrowsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
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

    override func setObject(move: inout ArrowsGameMove) -> GameChangeType {
        let p = move.p
        guard game.isArrow(p: p) && self[p] != move.obj else { return .none }
        self[p] = move.obj
        updateIsSolved()
        return .level
    }
    
    override func switchObject(move: inout ArrowsGameMove) -> GameChangeType {
        let p = move.p
        guard game.isArrow(p: p) else { return .none }
        let o = self[p]
        move.obj = (o + 1) % 9
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games/Puzzle Set 6/Arrows

        Summary
        Just Arrows?

        Description
        1. The goal is to detect the arrows directions that reside outside the board.
        2. Each Arrow points to at least one number inside the board.
        3. The numbers tell you how many arrows point at them.
        4. There is one arrow for each tile outside the board.
    */
    private func updateIsSolved() {
        isSolved = true
//        var chars = [Character]()
//        for r in 1..<rows - 1 {
//            let (h1, h2) = (self[r, 0], self[r, cols - 1])
//            var (ch11, ch21): (Character, Character) = (" ", " ")
//            chars = []
//            for c in 1..<cols - 1 {
//                let (ch12, ch22) = (self[r, c], self[r, cols - 1 - c])
//                if ch11 == " " && ch12 != " " { ch11 = ch12 }
//                if ch21 == " " && ch22 != " " { ch21 = ch22 }
//                guard ch12 != " " else {continue}
//                // 2. Each letter appears once in every row.
//                if chars.contains(ch12) {
//                    isSolved = false
//                } else {
//                    chars.append(ch12)
//                }
//            }
//            // 3. The letters on the borders tell you what letter you see from there.
//            let s1: HintState = ch11 == " " ? .normal : ch11 == h1 ? .complete : .error
//            let s2: HintState = ch21 == " " ? .normal : ch21 == h2 ? .complete : .error
//            row2state[r * 2] = s1; row2state[r * 2 + 1] = s2
//            if s1 != .complete || s2 != .complete { isSolved = false }
//            // 2. Each letter appears once in every row.
//            if chars.count != Int(game.chMax.asciiValue!) - Int(Character("A").asciiValue!) + 1 { isSolved = false }
//        }
//        for c in 1..<cols - 1 {
//            let (h1, h2) = (self[0, c], self[rows - 1, c])
//            var (ch11, ch21): (Character, Character) = (" ", " ")
//            chars = []
//            for r in 1..<rows - 1 {
//                let (ch12, ch22) = (self[r, c], self[rows - 1 - r, c])
//                if ch11 == " " && ch12 != " " { ch11 = ch12 }
//                if ch21 == " " && ch22 != " " { ch21 = ch22 }
//                guard ch12 != " " else {continue}
//                // 2. Each letter appears once in every column.
//                if chars.contains(ch12) {
//                    isSolved = false
//                } else {
//                    chars.append(ch12)
//                }
//            }
//            // 3. The letters on the borders tell you what letter you see from there.
//            let s1: HintState = ch11 == " " ? .normal : ch11 == h1 ? .complete : .error
//            let s2: HintState = ch21 == " " ? .normal : ch21 == h2 ? .complete : .error
//            col2state[c * 2] = s1; col2state[c * 2 + 1] = s2
//            if s1 != .complete || s2 != .complete { isSolved = false }
//            // 2. Each letter appears once in every column.
//            if chars.count != Int(game.chMax.asciiValue!) - Int(Character("A").asciiValue!) + 1 { isSolved = false }
//        }
    }
}
