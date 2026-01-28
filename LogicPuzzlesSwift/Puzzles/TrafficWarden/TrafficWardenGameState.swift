//
//  TrafficWardenGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class TrafficWardenGameState: GridGameState<TrafficWardenGameMove> {
    var game: TrafficWardenGame {
        get { getGame() as! TrafficWardenGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { TrafficWardenDocument.sharedInstance }
    var objArray = [TrafficWardenObject]()
    
    override func copy() -> TrafficWardenGameState {
        let v = TrafficWardenGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: TrafficWardenGameState) -> TrafficWardenGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: TrafficWardenGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<TrafficWardenObject>(repeating: TrafficWardenObject(repeating: false, count: 4), count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> TrafficWardenObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> TrafficWardenObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout TrafficWardenGameMove) -> GameOperationType {
        let p = move.p, dir = move.dir
        let p2 = p + TrafficWardenGame.offset[dir], dir2 = (dir + 2) % 4
        guard isValid(p: p2) && game[p] != TrafficWardenGame.PUZ_BLOCK && game[p2] != TrafficWardenGame.PUZ_BLOCK else { return .invalid }
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
                } else if !(dirs.isEmpty && game[p] == TrafficWardenGame.PUZ_BLOCK) {
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
            p2 += TrafficWardenGame.offset[n]
            guard p2 != p else {break}
        }
    }
}
