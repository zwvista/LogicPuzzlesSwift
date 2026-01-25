//
//  FingerPointingGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class FingerPointingGameState: GridGameState<FingerPointingGameMove> {
    var game: FingerPointingGame {
        get { getGame() as! FingerPointingGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { FingerPointingDocument.sharedInstance }
    var objArray = [FingerPointingObject]()
    var pos2state = [Position: HintState]()

    override func copy() -> FingerPointingGameState {
        let v = FingerPointingGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: FingerPointingGameState) -> FingerPointingGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: FingerPointingGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        updateIsSolved()
    }
    
    subscript(p: Position) -> FingerPointingObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> FingerPointingObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout FingerPointingGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] != .block && game[p] != .hint && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout FingerPointingGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] != .block && game[p] != .hint else { return .invalid }
        let o = self[p]
        move.obj =
            o == .empty ? .up :
            o == .up ? .right :
            o == .right ? .down :
            o == .down ? .left :
            o == .left ? .empty :
            o
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 3/Puzzle Set 5/Finger Pointing

        Summary
        Blame is in the air

        Description
        1. Fill the board with fingers. Two fingers pointing in the same direction
           can't be orthogonally adjacent.
        2. the number tells you how many fingers and finger 'trails' point to that tile.
    */
    private func updateIsSolved() {
        isSolved = true
        var pos2rng = [Position: Set<Position>]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                var o = self[p]
                if o == .empty { isSolved = false; continue }
                if o == .block || o == .hint {continue}
                pos2state[p] = pos2state[p] ?? .normal
                let rng = FingerPointingGame.offset.map { p + $0 }.filter { isValid(p: $0) && self[$0] == o }
                if !rng.isEmpty {
                    isSolved = false
                    for p in rng { pos2state[p] = .error }
                }
                var p2 = p
                var rng2 = [Position]()
                while true {
                    rng2.append(p2)
                    p2 += FingerPointingGame.offset[o.rawValue - FingerPointingObject.up.rawValue]
                    guard isValid(p: p2) else {break}
                    o = self[p2]
                    if o == .empty { isSolved = false; break }
                    if o == .block {break}
                    if o == .hint {
                        for p3 in rng2 { pos2rng[p2, default: []].insert(p3) }
                        break
                    }
                }
            }
        }
        for (p, n2) in game.pos2hint {
            let n1 = (pos2rng[p] ?? []).count
            let s: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            if s != .complete { isSolved = false }
            pos2state[p] = s
        }
    }
}
