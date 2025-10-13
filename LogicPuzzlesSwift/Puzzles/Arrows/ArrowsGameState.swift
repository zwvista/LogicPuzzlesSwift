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
    var objArray = [Character]()
    var row2state = [HintState]()
    var col2state = [HintState]()
    
    override func copy() -> ArrowsGameState {
        let v = ArrowsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: ArrowsGameState) -> ArrowsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.row2state = row2state
        v.col2state = col2state
        return v
    }
    
    required init(game: ArrowsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<Character>(repeating: " ", count: rows * cols)
        row2state = Array<HintState>(repeating: .normal, count: rows * 2)
        col2state = Array<HintState>(repeating: .normal, count: cols * 2)
        for r in 0..<rows {
            for c in 0..<cols {
                self[r, c] = game[r, c]
            }
        }
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
    
    func pos2state(row: Int, col: Int) -> HintState {
        row == 0 && 1..<cols - 1 ~= col ? col2state[col * 2] :
            row == rows - 1 && 1..<cols - 1 ~= col ? col2state[col * 2 + 1] :
            col == 0 && 1..<rows - 1 ~= row ? row2state[row * 2] :
            col == cols - 1 && 1..<rows - 1 ~= row ? row2state[row * 2 + 1] :
            .normal
    }
    
    override func setObject(move: inout ArrowsGameMove) -> GameChangeType {
        let p = move.p
        guard isValid(p: p) && self[p] != move.obj else { return .none }
        self[p] = move.obj
        updateIsSolved()
        return .level
    }
    
    override func switchObject(move: inout ArrowsGameMove) -> GameChangeType {
        let p = move.p
        guard isValid(p: p) else { return .none }
        let o = self[p]
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        move.obj =
            o == " " ? markerOption == .markerFirst ? "." : "A" :
            o == "." ? markerOption == .markerFirst ? "A" : " " :
            o == game.chMax ? markerOption == .markerLast ? "." : " " :
            succ(ch: o)
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 1/Arrows

        Summary
        Fill the board with ABC

        Description
        1. The goal is to put the letter A B and C in the board.
        2. Each letter appears once in every row and column.
        3. The letters on the borders tell you what letter you see from there.
        4. Since most puzzles can contain empty spaces, the hint on the board
           doesn't always match the tile next to it.
        5. Bigger puzzles can contain the letter 'D'. In these cases, the name
           of the puzzle is 'Arrowsd'. Further on, you might also encounter 'E',
           'F' etc.
    */
    private func updateIsSolved() {
        isSolved = true
        var chars = [Character]()
        for r in 1..<rows - 1 {
            let (h1, h2) = (self[r, 0], self[r, cols - 1])
            var (ch11, ch21): (Character, Character) = (" ", " ")
            chars = []
            for c in 1..<cols - 1 {
                let (ch12, ch22) = (self[r, c], self[r, cols - 1 - c])
                if ch11 == " " && ch12 != " " { ch11 = ch12 }
                if ch21 == " " && ch22 != " " { ch21 = ch22 }
                guard ch12 != " " else {continue}
                // 2. Each letter appears once in every row.
                if chars.contains(ch12) {
                    isSolved = false
                } else {
                    chars.append(ch12)
                }
            }
            // 3. The letters on the borders tell you what letter you see from there.
            let s1: HintState = ch11 == " " ? .normal : ch11 == h1 ? .complete : .error
            let s2: HintState = ch21 == " " ? .normal : ch21 == h2 ? .complete : .error
            row2state[r * 2] = s1; row2state[r * 2 + 1] = s2
            if s1 != .complete || s2 != .complete { isSolved = false }
            // 2. Each letter appears once in every row.
            if chars.count != Int(game.chMax.asciiValue!) - Int(Character("A").asciiValue!) + 1 { isSolved = false }
        }
        for c in 1..<cols - 1 {
            let (h1, h2) = (self[0, c], self[rows - 1, c])
            var (ch11, ch21): (Character, Character) = (" ", " ")
            chars = []
            for r in 1..<rows - 1 {
                let (ch12, ch22) = (self[r, c], self[rows - 1 - r, c])
                if ch11 == " " && ch12 != " " { ch11 = ch12 }
                if ch21 == " " && ch22 != " " { ch21 = ch22 }
                guard ch12 != " " else {continue}
                // 2. Each letter appears once in every column.
                if chars.contains(ch12) {
                    isSolved = false
                } else {
                    chars.append(ch12)
                }
            }
            // 3. The letters on the borders tell you what letter you see from there.
            let s1: HintState = ch11 == " " ? .normal : ch11 == h1 ? .complete : .error
            let s2: HintState = ch21 == " " ? .normal : ch21 == h2 ? .complete : .error
            col2state[c * 2] = s1; col2state[c * 2 + 1] = s2
            if s1 != .complete || s2 != .complete { isSolved = false }
            // 2. Each letter appears once in every column.
            if chars.count != Int(game.chMax.asciiValue!) - Int(Character("A").asciiValue!) + 1 { isSolved = false }
        }
    }
}
