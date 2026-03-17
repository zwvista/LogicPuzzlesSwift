//
//  FunnyNumbersGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class FunnyNumbersGameState: GridGameState<FunnyNumbersGameMove> {
    var game: FunnyNumbersGame {
        get { getGame() as! FunnyNumbersGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { FunnyNumbersDocument.sharedInstance }
    var objArray = [Int]()
    var row2state = [HintState]()
    var col2state = [HintState]()
    var pos2state = [Position: AllowedObjectState]()

    override func copy() -> FunnyNumbersGameState {
        let v = FunnyNumbersGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: FunnyNumbersGameState) -> FunnyNumbersGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.row2state = row2state
        v.col2state = col2state
        return v
    }
    
    required init(game: FunnyNumbersGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        row2state = Array<HintState>(repeating: .normal, count: rows)
        col2state = Array<HintState>(repeating: .normal, count: cols)
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
    
    override func setObject(move: inout FunnyNumbersGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == 0 && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout FunnyNumbersGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == 0 else { return .invalid }
        let o = self[p]
        move.obj = (o + 1) % (game.areas[game.pos2area[p]!].count + 1)
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 4/Puzzle Set 2/Funny Numbers

        Summary
        Hahaha ... haha ... ehm ...

        Description
        1. Fill each region with numbers 1 to X where the X is the region area.
        2. Same numbers can't touch each other horizontally or vertically across regions.
        3. The numbers outside tell you the sum of the row or column.
    */
    private func updateIsSolved() {
        isSolved = true
        for area in game.areas {
            // 2. Same numbers can't touch each other horizontally or vertically across regions.
            for p in area {
                let n = self[p]
                pos2state[p] = n > 0 && (FunnyNumbersGame.offset.contains {
                    let p2 = p + $0
                    return isValid(p: p2) && self[p2] == n
                }) ? .error : .normal
            }
            // 1. Fill each region with numbers 1 to X where the X is the region area.
            let num2rng = Dictionary(grouping: area) { self[$0] }
                .filter { num, rng in num != 0 && rng.count > 1 }
            if !num2rng.isEmpty {
                isSolved = false
                for (_, rng) in num2rng {
                    for p in rng { pos2state[p] = .error }
                }
            }
        }
        // 3. The numbers outside tell you the sum of the row or column.
        for r in 0..<rows {
            let n2 = game.row2hint[r]
            guard n2 > 0 else {continue}
            let n1 = (0..<cols).reduce(0) { $0 + self[r, $1] }
            let s: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            row2state[r] = s
            if s != .complete { isSolved = false }
        }
        // 3. The numbers outside tell you the sum of the row or column.
        for c in 0..<cols {
            let n2 = game.col2hint[c]
            guard n2 > 0 else {continue}
            let n1 = (0..<rows).reduce(0) { $0 + self[$1, c] }
            let s: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            col2state[c] = s
            if s != .complete { isSolved = false }
        }
    }
}
