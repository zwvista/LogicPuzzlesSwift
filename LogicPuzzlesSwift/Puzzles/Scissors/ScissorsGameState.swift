//
//  ScissorsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class ScissorsGameState: GridGameState<ScissorsGameMove> {
    var game: ScissorsGame {
        get { getGame() as! ScissorsGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { ScissorsDocument.sharedInstance }
    var objArray = [ScissorsObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> ScissorsGameState {
        let v = ScissorsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: ScissorsGameState) -> ScissorsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: ScissorsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<ScissorsObject>(repeating: .empty, count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> ScissorsObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> ScissorsObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout ScissorsGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout ScissorsGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) else { return .invalid }
        let o = self[p]
        move.obj = switch o {
        case .empty: .forward
        case .forward: .backward
        case .backward: .empty
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 3/Puzzle Set 1/Scissors

        Summary
        Tailor's puzzle

        Description
        1. Cut the board into patches.
        2. Each patch should contain the numbers 1 to N exactly once (N being the highest number on the board).
        3. Each patch should end on the border.
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
                case .forward:
                    addSlash(p1: p, p2: p + ScissorsGame.offset2[3])
                case .backward:
                    addSlash(p1: p + ScissorsGame.offset2[1], p2: p + ScissorsGame.offset2[2])
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
