//
//  CrossroadBlocksGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class CrossroadBlocksGameState: GridGameState<CrossroadBlocksGameMove> {
    var game: CrossroadBlocksGame {
        get { getGame() as! CrossroadBlocksGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { CrossroadBlocksDocument.sharedInstance }
    var objArray = [CrossroadBlocksObject]()
    
    override func copy() -> CrossroadBlocksGameState {
        let v = CrossroadBlocksGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: CrossroadBlocksGameState) -> CrossroadBlocksGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: CrossroadBlocksGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<CrossroadBlocksObject>(repeating: CrossroadBlocksObject(repeating: false, count: 4), count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> CrossroadBlocksObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> CrossroadBlocksObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout CrossroadBlocksGameMove) -> GameOperationType {
        let p = move.p, dir = move.dir
        let p2 = p + CrossroadBlocksGame.offset[dir], dir2 = (dir + 2) % 4
        guard isValid(p: p2) && game[p] != CrossroadBlocksGame.PUZ_BLOCK && game[p2] != CrossroadBlocksGame.PUZ_BLOCK else { return .invalid }
        self[p][dir].toggle()
        self[p2][dir2].toggle()
        updateIsSolved()
        return .moveComplete
    }
    
    
    /*
        iOS Game: 100 Logic Games 3/Puzzle Set 4/Crossroad Blocks

        Summary
        Steer before the roadblock!

        Description
        1. Try to drive around the circuit without hitting the road blocks:
           draw a single closed non-intersecting loop.
        2. The arrows and numbers tell you the total number of cells borders
           the road crosses in that direction.
        3. In the example, looking at the top stretch, the road goes through
           4 cells, hence it crosses 3 cell borders.
        4. Also on the top left, the road goes through 2 cells and so it crosses
           one cell border.
        5. Black cells must be inside the loop. White cells must be outside the loop.
        6. The number tells you the total tiles crossed in that direction.
           So that could be split in two stretches or more.
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
                } else if !(dirs.isEmpty && game[p] == CrossroadBlocksGame.PUZ_BLOCK) {
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
            p2 += CrossroadBlocksGame.offset[n]
            guard p2 != p else {break}
        }
    }
}
