//
//  SnakeMazeGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class SnakeMazeGameState: GridGameState<SnakeMazeGameMove> {
    var game: SnakeMazeGame {
        get { getGame() as! SnakeMazeGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { SnakeMazeDocument.sharedInstance }
    var objArray = [SnakeMazeObject]()
    var squares = Set<Position>()
    var pos2stateHint = [Position: HintState]()
    var pos2stateAllowed = [Position: AllowedObjectState]()
    
    override func copy() -> SnakeMazeGameState {
        let v = SnakeMazeGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: SnakeMazeGameState) -> SnakeMazeGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.squares = squares
        return v
    }
    
    required init(game: SnakeMazeGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<SnakeMazeObject>(repeating: SnakeMazeObject(repeating: false, count: 4), count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> SnakeMazeObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> SnakeMazeObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout SnakeMazeGameMove) -> GameOperationType {
        let p = move.p, dir = move.dir
        guard isValid(p: p) else { return .invalid }
        if dir == SnakeMazeGame.PUZ_DIR_SQUARE {
            guard self[p].testAll(is: false) else { return .invalid }
            if squares.remove(p) == nil { squares.insert(p) }
        } else {
            let p2 = p + SnakeMazeGame.offset[dir], dir2 = (dir + 2) % 4
            guard isValid(p: p2) && game.pos2hint[p] == nil && !squares.contains(p) && !squares.contains(p2) else { return .invalid }
            self[p][dir].toggle()
            self[p2][dir2].toggle()
        }
        updateIsSolved()
        return .moveComplete
    }
    
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 7/Snake Maze

        Summary
        Find the snakes using the given hints.

        Description
        1. A Snake is a path of five tiles, numbered 1-2-3-4-5, where 1 is the head and 5 the tail.
           The snake's body segments are connected horizontally or vertically.
        2. A snake cannot see another snake or it would attack it. A snake sees straight in the
           direction 2-1, that is to say it sees in front of the number 1.
        3. A snake cannot touch another snake horizontally or vertically.
        4. Arrows show you the closest piece of Snake in that direction (before another arrow or the edge).
        5. Arrows with zero mean that there is no Snake in that direction.
        6. Arrows block snake sight and also block other arrows hints.
    */
    private func updateIsSolved() {
        isSolved = true
        // 4. It is up to you to find the Squares, which are pointed at by the Arrows!
        // 5. The numbers beside the Arrows tell you how many Squares are present
        //    in that direction, from that point.
        for (p, hint) in game.pos2hint {
            let n2 = hint.num
            let os = SnakeMazeGame.offset[hint.dir]
            var n1 = 0
            var p2 = p + os
            while isValid(p: p2) {
                if squares.contains(p2) { n1 += 1 }
                p2 += os
            }
            let s: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            pos2stateHint[p] = s
            if s != .complete { isSolved = false }
        }
        // 6. The Squares can't touch horizontally or vertically.
        for p in squares {
            let s: AllowedObjectState = (!SnakeMazeGame.offset.contains {
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
                    // 1. Draw a loop that runs through all tiles.
                    pos2dirs[p] = dirs
                } else if !(dirs.isEmpty && (game.pos2hint[p] != nil || squares.contains(p))) {
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
            p2 += SnakeMazeGame.offset[n]
            guard p2 != p else {break}
        }
    }
}
