//
//  RunInALoopGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class RunInALoopGameState: GridGameState<RunInALoopGameMove> {
    var game: RunInALoopGame {
        get { getGame() as! RunInALoopGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { RunInALoopDocument.sharedInstance }
    var objArray = [RunInALoopObject]()
    
    override func copy() -> RunInALoopGameState {
        let v = RunInALoopGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: RunInALoopGameState) -> RunInALoopGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: RunInALoopGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<RunInALoopObject>(repeating: RunInALoopObject(repeating: false, count: 4), count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> RunInALoopObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> RunInALoopObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout RunInALoopGameMove) -> GameOperationType {
        let p = move.p, dir = move.dir
        let p2 = p + RunInALoopGame.offset[dir], dir2 = (dir + 2) % 4
        guard isValid(p: p2) && game[p] != RunInALoopGame.PUZ_BLOCK && game[p2] != RunInALoopGame.PUZ_BLOCK else { return .invalid }
        self[p][dir].toggle()
        self[p2][dir2].toggle()
        updateIsSolved()
        return .moveComplete
    }
    
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 3/Run in a Loop

        Summary
        Loop a loop

        Description
        1. Draw a loop that runs through all tiles.
        2. The loop cannot cross itself.
    */
    private func updateIsSolved() {
        isSolved = true
        var pos2dirs = [Position: [Int]]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let dirs = (0..<4).filter { self[p][$0] }
                if dirs.count == 2 {
                    // 1. Draw a loop that runs through all tiles.
                    pos2dirs[p] = dirs
                } else if !(dirs.isEmpty && game[p] == RunInALoopGame.PUZ_BLOCK) {
                    // 2. The loop cannot cross itself.
                    isSolved = false; return
                }
            }
        }
        // Check the loop
        let p = pos2dirs.keys.first!
        var p2 = p, n = -1
        while true {
            guard let dirs = pos2dirs[p2] else { isSolved = false; return }
            pos2dirs.removeValue(forKey: p2)
            n = dirs.first { ($0 + 2) % 4 != n }!
            p2 += RunInALoopGame.offset[n]
            guard p2 != p else {return}
        }
    }
}
