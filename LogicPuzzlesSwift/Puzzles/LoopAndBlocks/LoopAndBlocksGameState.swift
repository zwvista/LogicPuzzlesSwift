//
//  LoopAndBlocksGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class LoopAndBlocksGameState: GridGameState<LoopAndBlocksGameMove> {
    var game: LoopAndBlocksGame {
        get { getGame() as! LoopAndBlocksGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { LoopAndBlocksDocument.sharedInstance }
    var objArray = [LoopAndBlocksObject]()
    var squares = Set<Position>()
    var pos2stateHint = [Position: HintState]()
    var pos2stateAllowed = [Position: AllowedObjectState]()

    override func copy() -> LoopAndBlocksGameState {
        let v = LoopAndBlocksGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: LoopAndBlocksGameState) -> LoopAndBlocksGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.squares = squares
        return v
    }
    
    required init(game: LoopAndBlocksGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<LoopAndBlocksObject>(repeating: LoopAndBlocksObject(repeating: false, count: 4), count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> LoopAndBlocksObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> LoopAndBlocksObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout LoopAndBlocksGameMove) -> GameOperationType {
        let p = move.p, dir = move.dir
        guard isValid(p: p) else { return .invalid }
        if dir == LoopAndBlocksGame.PUZ_DIR_SQUARE {
            guard self[p].testAll(is: false) else { return .invalid }
            if squares.remove(p) == nil { squares.insert(p) }
        } else {
            let p2 = p + LoopAndBlocksGame.offset[dir], dir2 = (dir + 2) % 4
            guard isValid(p: p2) && game.pos2hint[p] == nil && !squares.contains(p) && !squares.contains(p2) else { return .invalid }
            self[p][dir].toggle()
            self[p2][dir2].toggle()
        }
        updateIsSolved()
        return .moveComplete
    }
    
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 7/Loop and Blocks

        Summary
        Don't block me now

        Description
        1. Draw a loop that passes through each clear tile.
        2. The loop must be a single one and can't intersect itself.
        3. A number in a cell shows how many cell must be shaded around its
           four sides.
        4. Not all cells that must be shaded are given with a hint. Two shaded
           cells can't touch orthogonally.
        5. The loop must pass over every cell that hasn't got a number or has
           not been shaded.
    */
    private func updateIsSolved() {
        isSolved = true
        // 3. A number in a cell shows how many cell must be shaded around its
        //    four sides.
        // 4. Not all cells that must be shaded are given with a hint.
        for (p, n2) in game.pos2hint {
            let n1 = LoopAndBlocksGame.offset.count { squares.contains(p + $0) }
            let s: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            pos2stateHint[p] = s
            if s != .complete { isSolved = false }
        }
        // 4. Two shaded cells can't touch orthogonally.
        for p in squares {
            let s: AllowedObjectState = (!LoopAndBlocksGame.offset.contains {
                squares.contains(p + $0)
            }) ? .normal : .error
            pos2stateAllowed[p] = s
            if s == .error { isSolved = false }
        }
        guard isSolved else {return}
        var pos2dirs = [Position: [Int]]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let dirs = (0..<4).filter { self[p][$0] }
                if dirs.count == 2 {
                    // 1. Draw a loop that passes through each clear tile.
                    pos2dirs[p] = dirs
                } else if !(dirs.isEmpty && (game.pos2hint[p] != nil || squares.contains(p))) {
                    // 2. The loop must be a single one and can't intersect itself.
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
            p2 += YalooniqGame.offset[n]
            guard p2 != p else {break}
        }
    }
}
