//
//  SlantedMazeGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class SlantedMazeGameState: GridGameState<SlantedMazeGameMove> {
    var game: SlantedMazeGame {
        get { getGame() as! SlantedMazeGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { SlantedMazeDocument.sharedInstance }
    var objArray = [SlantedMazeObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> SlantedMazeGameState {
        let v = SlantedMazeGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: SlantedMazeGameState) -> SlantedMazeGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: SlantedMazeGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<SlantedMazeObject>(repeating: .empty, count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> SlantedMazeObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> SlantedMazeObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout SlantedMazeGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout SlantedMazeGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) else { return .invalid }
        let o = self[p]
        move.obj = switch o {
        case .empty: .backward
        case .backward: .forward
        case .forward: .empty
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games/Puzzle Set 6/Slanted Maze

        Summary
        Maze of Slants!

        Description
        1. Fill the board with diagonal lines (Slants), following the hints at
           the intersections.
        2. Every number tells you how many Slants (diagonal lines) touch that
           point. So, for example, a 4 designates an X pattern around it.
        3. The Mazes or paths the Slants will form will usually branch off many
           times, but can also end abruptly. Also all the Slants don't need to
           be all connected.
        4. However, you must ensure that they don't form a closed loop anywhere.
           This also means very big loops, not just 2*2.
    */
    private func updateIsSolved() {
        isSolved = true
        var matrix = [Position: [Position]]()
        var rng = Set<Position>()
        // 1. Fill the board with diagonal lines (Slants), following the hints at
        //    the intersections.
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                func addSlash(p1: Position, p2: Position) {
                    matrix[p1, default: []].append(p2)
                    matrix[p2, default: []].append(p1)
                    rng.insert(p1)
                    rng.insert(p2)
                }
                switch self[p] {
                case .backward:
                    addSlash(p1: p, p2: p + SlantedMazeGame.offset2[3])
                case .forward:
                    addSlash(p1: p + SlantedMazeGame.offset2[1], p2: p + SlantedMazeGame.offset2[2])
                case .empty:
                    isSolved = false
                }
            }
        }
        // 2. Every number tells you how many Slants (diagonal lines) touch that
        //    point. So, for example, a 4 designates an X pattern around it.
        for (p, n2) in game.pos2hint {
            let n1 = matrix[p, default: []].count
            let s: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            pos2state[p] = s
            if s != .complete { isSolved = false }
        }
        if !isSolved {return}
        // 3. The Mazes or paths the Slants will form will usually branch off many
        //    times, but can also end abruptly. Also all the Slants don't need to
        //    be all connected.
        // 4. However, you must ensure that they don't form a closed loop anywhere.
        //    This also means very big loops, not just 2*2.
        while !rng.isEmpty {
            var moves = Set<Position>()
            func dfs(p: Position, pLast: Position) -> Bool {
                guard moves.insert(p).inserted else { return false }
                for p2 in matrix[p]! {
                    if p2 == pLast {continue}
                    guard dfs(p: p2, pLast: p) else { return false }
                }
                return true
            }
            guard dfs(p: rng.first!, pLast: Position(-1, -1)) else { isSolved = false; return }
            for p in moves { rng.remove(p) }
        }
    }
}
