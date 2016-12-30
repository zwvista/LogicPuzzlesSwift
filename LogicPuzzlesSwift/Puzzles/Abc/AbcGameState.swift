//
//  AbcGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class AbcGameState: GridGameState, AbcMixin {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: AbcGame {
        get {return getGame() as! AbcGame}
        set {setGame(game: newValue)}
    }
    var objArray = [Character]()
    var row2state = [HintState]()
    var col2state = [HintState]()
    
    override func copy() -> AbcGameState {
        let v = AbcGameState(game: game)
        return setup(v: v)
    }
    func setup(v: AbcGameState) -> AbcGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.row2state = row2state
        v.col2state = col2state
        return v
    }
    
    required init(game: AbcGame) {
        super.init(game: game)
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
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> Character {
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
            .normal;
    }
    
    func setObject(move: inout AbcGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) && self[p] != move.obj else {return false}
        self[p] = move.obj
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout AbcGameMove) -> Bool {
        func f(ch: Character) -> Character {
            // http://stackoverflow.com/questions/26761390/changing-value-of-character-using-ascii-value-in-swift
            let scalars = String(ch).unicodeScalars      // unicode scalar(s) of the character
            let val = scalars[scalars.startIndex].value  // value of the unicode scalar
            return Character(UnicodeScalar(val + 1)!)     // return an incremented character
        }
        let p = move.p
        guard isValid(p: p) else {return false}
        let o = self[p]
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        move.obj =
            o == " " ? markerOption == .markerFirst ? "." : "A" :
            o == "." ? markerOption == .markerFirst ? "A" : " " :
            o == game.chMax ? markerOption == .markerLast ? "." : " " :
            f(ch: o)
        return setObject(move: &move)
    }
    
    private func updateIsSolved() {
        isSolved = true
        var chars = [Character]()
        for r in 1..<rows - 1 {
            let (h1, h2) = (self[r, 0], self[r, cols - 1])
            var (ch11, ch21): (Character, Character) = (" ", " ")
            chars = []
            for c in 1..<cols - 1 {
                let (ch12, ch22) = (self[r, c], self[r, cols - 1 - c])
                if ch11 == " " && ch12 != " " {ch11 = ch12}
                if ch21 == " " && ch22 != " " {ch21 = ch22}
                guard ch12 != " " else {continue}
                if chars.contains(ch12) {
                    isSolved = false
                } else {
                    chars.append(ch12)
                }
            }
            let s1: HintState = ch11 == " " ? .normal : ch11 == h1 ? .complete : .error
            let s2: HintState = ch21 == " " ? .normal : ch21 == h2 ? .complete : .error
            row2state[r * 2] = s1; row2state[r * 2 + 1] = s2
            if s1 != .complete || s2 != .complete {isSolved = false}
            if chars.count != Int(game.chMax.asciiValue!) - Int(Character("A").asciiValue!) + 1 {isSolved = false}
        }
        for c in 1..<cols - 1 {
            let (h1, h2) = (self[0, c], self[rows - 1, c])
            var (ch11, ch21): (Character, Character) = (" ", " ")
            chars = []
            for r in 1..<rows - 1 {
                let (ch12, ch22) = (self[r, c], self[rows - 1 - r, c])
                if ch11 == " " && ch12 != " " {ch11 = ch12}
                if ch21 == " " && ch22 != " " {ch21 = ch22}
                guard ch12 != " " else {continue}
                if chars.contains(ch12) {
                    isSolved = false
                } else {
                    chars.append(ch12)
                }
            }
            let s1: HintState = ch11 == " " ? .normal : ch11 == h1 ? .complete : .error
            let s2: HintState = ch21 == " " ? .normal : ch21 == h2 ? .complete : .error
            col2state[c * 2] = s1; col2state[c * 2 + 1] = s2
            if s1 != .complete || s2 != .complete {isSolved = false}
            if chars.count != Int(game.chMax.asciiValue!) - Int(Character("A").asciiValue!) + 1 {isSolved = false}
        }
    }
}
