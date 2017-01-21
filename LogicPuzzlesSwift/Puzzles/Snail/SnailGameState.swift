//
//  SnailGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class SnailGameState: GridGameState, SnailMixin {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: SnailGame {
        get {return getGame() as! SnailGame}
        set {setGame(game: newValue)}
    }
    var objArray = [Character]()
    
    override func copy() -> SnailGameState {
        let v = SnailGameState(game: game)
        return setup(v: v)
    }
    func setup(v: SnailGameState) -> SnailGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: SnailGame) {
        super.init(game: game);
        objArray = game.objArray
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
    
    func setObject(move: inout SnailGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) && game[p] == " " && self[p] != move.obj else {return false}
        self[p] = move.obj
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout SnailGameMove) -> Bool {
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
            o == " " ? markerOption == .markerFirst ? "." : "1" :
            o == "." ? markerOption == .markerFirst ? "1" : " " :
            o == "3" ? markerOption == .markerLast ? "." : " " :
            f(ch: o)
        return setObject(move: &move)
    }
    
    private func updateIsSolved() {
        isSolved = true
        var chars = [Character]()
        for r in 0..<rows {
            chars = []
            for c in 0..<cols {
                let ch = self[r, c]
                guard ch != " " else {continue}
                if chars.contains(ch) {
                    isSolved = false
                } else {
                    chars.append(ch)
                }
            }
            if chars.count != 3 {isSolved = false}
        }
        for c in 0..<cols {
            chars = []
            for r in 0..<rows {
                let ch = self[r, c]
                guard ch != " " else {continue}
                if chars.contains(ch) {
                    isSolved = false
                } else {
                    chars.append(ch)
                }
            }
            if chars.count != 3 {isSolved = false}
        }
        chars = []
        for p in game.snailPathGrid {
            let ch = self[p]
            guard ch != " " else {continue}
            chars.append(ch)
        }
        if chars[0] != "1" || chars[chars.count - 1] != "3" {isSolved = false}
        for i in 0..<chars.count - 1 {
            switch (chars[i], chars[i + 1]) {
            case ("1", "2"), ("2", "3"), ("3", "1"):
                break
            default:
                isSolved = false
            }
        }
    }
}
