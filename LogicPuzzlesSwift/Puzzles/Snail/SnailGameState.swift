//
//  SnailGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class SnailGameState: GridGameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: SnailGame {
        get {getGame() as! SnailGame}
        set {setGame(game: newValue)}
    }
    var gameDocument: SnailDocument { SnailDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { SnailDocument.sharedInstance }
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
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> Character {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
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
    
    /*
        iOS Game: Logic Games/Puzzle Set 14/Snail

        Summary
        Follow the winding path with numbers 1, 2 and 3

        Description
        1. The goal is to start at the entrance in the top left corner and proceed
           towards the center, leaving a trail of numbers.
        2. The numbers must be entered in the sequence 1,2,3 1,2,3 1,2,3 etc,
           however not every tile must be filled in and some tiles will remain
           empty.
        3. Your task is to determine which tiles will be empty, following these
           two rules:
        4. Trail Rule: The first number to write after entering in the top left
           is a 1 and the last before ending in the center is a 3. In between,
           the 1,2,3 sequence will repeat many times in this order, following the
           snail path.
        5. Board Rule: Each row and column of the board (disregarding the snail
           path) must have exactly one 1, one 2 and one 3.
    */
    private func updateIsSolved() {
        isSolved = true
        var chars = [Character]()
        // 5. Board Rule: Each row of the board (disregarding the snail
        // path) must have exactly one 1, one 2 and one 3.
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
        // 5. Board Rule: Each column of the board (disregarding the snail
        // path) must have exactly one 1, one 2 and one 3.
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
        // 4. Trail Rule: The first number to write after entering in the top left
        // is a 1 and the last before ending in the center is a 3. In between,
        // the 1,2,3 sequence will repeat many times in this order, following the
        // snail path.
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
