//
//  TraceNumbersGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class TraceNumbersGameState: GridGameState<TraceNumbersGameMove> {
    var game: TraceNumbersGame {
        get { getGame() as! TraceNumbersGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { TraceNumbersDocument.sharedInstance }
    var objArray = [TraceNumbersObject]()
    
    override func copy() -> TraceNumbersGameState {
        let v = TraceNumbersGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: TraceNumbersGameState) -> TraceNumbersGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: TraceNumbersGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<TraceNumbersObject>(repeating: TraceNumbersObject(repeating: false, count: 4), count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> TraceNumbersObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> TraceNumbersObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout TraceNumbersGameMove) -> GameOperationType {
        let p = move.p, dir = move.dir
        let p2 = p + TraceNumbersGame.offset[dir], dir2 = (dir + 2) % 4
        guard isValid(p: p2) else { return .invalid }
        self[p][dir].toggle()
        self[p2][dir2].toggle()
        updateIsSolved()
        return .moveComplete
    }
    
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 1/Trace Numbers

        Summary
        Trace Numbers

        Description
        1. On the board there are a few number sets. Those numbers are
           sequences all starting from 1 up to a number N.
        2. You should draw as many lines into the grid as number sets:
           a line starts with the number 1, goes through the numbers in
           order up to the highest, where it ends.
        3. In doing this, you have to pass through all tiles on the board.
           Lines cannot cross.
    */
    private func updateIsSolved() {
        isSolved = true
        var chOneArray = [Position]()
        var ch2dirs = [Position: [Int]]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let o = self[p]
                let ch = game[p]
                let dirs = (0..<4).filter { o[$0] }
                switch dirs.count {
                case 1:
                    // 2. You should draw as many lines into the grid as number sets:
                    //    a line starts with the number 1, goes through the numbers in
                    //    order up to the highest, where it ends.
                    guard ch == TraceNumbersGame.PUZ_ONE || ch == game.chMax else { isSolved = false; return }
                    if ch == TraceNumbersGame.PUZ_ONE { chOneArray.append(p) }
                    ch2dirs[p] = dirs
                case 2:
                    ch2dirs[p] = dirs
                default:
                    // 3. In doing this, you have to pass through all tiles on the board.
                    //    Lines cannot cross.
                    isSolved = false; return
                }
            }
        }
        // 2. You should draw as many lines into the grid as number sets:
        //    a line starts with the number 1, goes through the numbers in
        //    order up to the highest, where it ends.
        for p in chOneArray {
            var chars = String(TraceNumbersGame.PUZ_ONE)
            var i = ch2dirs[p]!.first!
            var os = TraceNumbersGame.offset[i]
            var p2 = p + os
            while true {
                let ch = game[p2]
                if ch != " " { chars.append(ch) }
                let j = (i + 2) % 4
                var dirs = ch2dirs[p2]!
                dirs = dirs.filter { $0 != j }
                guard !dirs.isEmpty else {break}
                i = dirs.first!
                os = TraceNumbersGame.offset[i]
                p2 += os
            }
            if chars != game.expectedChars { isSolved = false; return }
        }
    }
}
