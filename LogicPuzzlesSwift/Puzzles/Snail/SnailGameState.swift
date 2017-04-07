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
    var pos2state = [Position: HintState]()
    var row2state = [HintState]()
    var col2state = [HintState]()
    
    override func copy() -> SnailGameState {
        let v = SnailGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: SnailGameState) -> SnailGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        v.row2state = row2state
        v.col2state = col2state
        return v
    }
    
    required init(game: SnailGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        row2state = Array<HintState>(repeating: .normal, count: rows)
        col2state = Array<HintState>(repeating: .normal, count: cols)
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
        let p = move.p
        guard isValid(p: p) && game[p] == " " else {return false}
        let o = self[p]
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        move.obj =
            o == " " ? markerOption == .markerFirst ? "." : "1" :
            o == "." ? markerOption == .markerFirst ? "1" : " " :
            o == "3" ? markerOption == .markerLast ? "." : " " :
            succ(ch: o)
        return setObject(move: &move)
    }
    
    private func updateIsSolved() {
        isSolved = true
        var chars = [Character]()
        for r in 0..<rows {
            chars = []
            row2state[r] = .complete
            for c in 0..<cols {
                let ch = self[r, c]
                guard ch != " " else {continue}
                guard !chars.contains(ch) else {break}
                chars.append(ch)
            }
            if chars.count != 3 {row2state[r] = .error; isSolved = false}
        }
        for c in 0..<cols {
            chars = []
            col2state[c] = .complete
            for r in 0..<rows {
                let ch = self[r, c]
                guard ch != " " else {continue}
                guard !chars.contains(ch) else {break}
                chars.append(ch)
            }
            if chars.count != 3 {col2state[c] = .error; isSolved = false}
        }
        var rng = [Position]()
        chars = []
        for p in game.snailPathGrid {
            let ch = self[p]
            pos2state[p] = .error
            guard ch != " " else {continue}
            rng.append(p)
            chars.append(ch)
            pos2state[p] = .complete
        }
        let cnt = chars.count
        if chars[0] != "1" {pos2state[rng[0]] = .error; isSolved = false}
        if chars[cnt - 1] != "3" {pos2state[rng[cnt - 1]] = .error; isSolved = false}
        for i in 0..<cnt - 1 {
            switch (chars[i], chars[i + 1]) {
            case ("1", "2"), ("2", "3"), ("3", "1"):
                break
            default:
                pos2state[rng[i]] = .error; isSolved = false
            }
        }
    }
}
