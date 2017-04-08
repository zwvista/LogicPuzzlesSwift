//
//  TatamiGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class TatamiGameState: GridGameState, TatamiMixin {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: TatamiGame {
        get {return getGame() as! TatamiGame}
        set {setGame(game: newValue)}
    }
    var objArray = [Character]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> TatamiGameState {
        let v = TatamiGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: TatamiGameState) -> TatamiGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: TatamiGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
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
    
    func setObject(move: inout TatamiGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) && game[p] == " " && self[p] != move.obj else {return false}
        self[p] = move.obj
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout TatamiGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) && game[p] == " " else {return false}
        let o = self[p]
        move.obj =
            o == " " ? "1" :
            o == "3" ? " " :
            succ(ch: o)
        return setObject(move: &move)
    }
    
    private func updateIsSolved() {
        isSolved = true
        let chars2: [Character] = ["1", "2", "3"]
        let chars3 = chars2.flatMap({Array<Character>(repeating: $0, count: rows / 3)})
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                if self[p] == " " {isSolved = false}
                pos2state[p] = .normal
            }
        }
        for r in 0..<rows {
            var lineSolved = true
            for c in 0..<cols - 1 {
                let (p1, p2) = (Position(r, c), Position(r, c + 1))
                let (ch1, ch2) = (self[p1], self[p2])
                guard ch1 != " " && ch2 != " " && ch1 == ch2 else {continue}
                isSolved = false; lineSolved = false
                pos2state[p1] = .error
                pos2state[p2] = .error
            }
            var chars = (0..<cols).map({self[r, $0]}).sorted()
            if chars[0] != " " && chars != chars3 {
                isSolved = false; lineSolved = false
                for c in 0..<cols {
                    pos2state[Position(r, c)] = .error
                }
            }
            if lineSolved {
                for c in 0..<cols {
                    pos2state[Position(r, c)] = .complete
                }
            }
        }
        for c in 0..<cols {
            var lineSolved = true
            for r in 0..<rows - 1 {
                let (p1, p2) = (Position(r, c), Position(r + 1, c))
                let (ch1, ch2) = (self[p1], self[p2])
                guard ch1 != " " && ch2 != " " && ch1 == ch2 else {continue}
                isSolved = false; lineSolved = false
                pos2state[p1] = .error
                pos2state[p2] = .error
            }
            var chars = (0..<rows).map({self[$0, c]}).sorted()
            if chars[0] != " " && chars != chars3 {
                isSolved = false; lineSolved = false
                for r in 0..<rows {
                    pos2state[Position(r, c)] = .error
                }
            }
            if lineSolved {
                for r in 0..<rows {
                    pos2state[Position(r, c)] = .complete
                }
            }
        }
        for a in game.areas {
            let chars = a.map({self[$0]}).sorted()
            guard chars[0] != " " && chars != chars2 else {continue}
            isSolved = false
            for p in a {
                pos2state[p] = .error
            }
        }
    }
}
