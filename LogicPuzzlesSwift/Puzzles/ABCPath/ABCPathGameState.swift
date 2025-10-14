//
//  ABCPathGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class ABCPathGameState: GridGameState<ABCPathGameMove> {
    var game: ABCPathGame {
        get { getGame() as! ABCPathGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { ABCPathDocument.sharedInstance }
    var objArray = [Character]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> ABCPathGameState {
        let v = ABCPathGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: ABCPathGameState) -> ABCPathGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: ABCPathGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<Character>(repeating: " ", count: rows * cols)
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
    
    override func setObject(move: inout ABCPathGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), game[p] == " ", self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout ABCPathGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), game[p] == " " else { return .invalid }
        let o = self[p]
        // 1.  Enter every letter from A to Y into the grid.
        var chars = (0...24).map { succ(ch: "A", offset: $0) }
        for r in 1..<rows - 1 {
            for c in 1..<cols - 1 {
                let p2 = Position(r, c)
                guard p2 != p else {continue}
                chars.removeFirst(self[p2])
            }
        }
        let i = chars.firstIndex(of: o) ?? chars.count - 1
        move.obj = o == " " ? chars[0] : i == chars.count - 1 ? " " : chars[i + 1]
        return setObject(move: &move)
    }
    
    /*
        https://www.brainbashers.com/showabcpath.asp
        ABC Path
     
        Description
        1.  Enter every letter from A to Y into the grid.
        2.  Each letter is next to the previous letter either horizontally, vertically or diagonally.
        3.  The clues around the edge tell you which row, column or diagonal each letter is in.
    */
    private func updateIsSolved() {
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                pos2state[Position(r, c)] = .normal
            }
        }
        var ch2rng = [Character: [Position]]()
        for r in 1..<rows - 1 {
            for c in 1..<cols - 1 {
                let p = Position(r, c)
                let ch = self[p]
                if ch == " " {
                    isSolved = false
                } else {
                    var rng = ch2rng[ch] ?? [Position]()
                    rng.append(p)
                    ch2rng[ch] = rng
                }
            }
        }
        ch2rng = ch2rng.filter { (ch, rng) in rng.count > 1 }
        if !ch2rng.isEmpty { isSolved = false }
        for (_, rng) in ch2rng {
            for p in rng {
                pos2state[p] = .error
            }
        }
        // 2.  Each letter is next to the previous letter either horizontally, vertically or diagonally.
        for r in 1..<rows - 1 {
            for c in 1..<cols - 1 {
                let p = Position(r, c)
                let ch = self[p]
                if pos2state[p] == .normal, ch == "A" || ABCPathGame.offset.contains(where: {
                    let p2 = p + $0
                    return isValid(p: p2) && self[p2] == succ(ch: ch, offset: -1)
                }) {
                    pos2state[p] = .complete
                } else {
                    isSolved = false
                }
            }
        }
        // 3.  The clues around the edge tell you which row, column or diagonal each letter is in.
        for (ch, p) in game.ch2pos {
            let (r, c) = (p.row, p.col)
            if (r == 0 || r == rows - 1) && r == c && (1..<rows - 1).contains(where: { self[$0, $0] == ch }) || (r == 0 || r == rows - 1) && r == rows - 1 - c && (1..<rows - 1).contains(where: { self[$0, rows - 1 - $0] == ch }) || (r == 0 || r == rows - 1) && (1..<rows - 1).contains(where: { self[$0, c] == ch })  || (c == 0 || c == cols - 1) && (1..<cols - 1).contains(where: { self[r, $0] == ch }) {
                pos2state[p] = .complete
            } else {
                isSolved = false
            }
        }
    }
}
