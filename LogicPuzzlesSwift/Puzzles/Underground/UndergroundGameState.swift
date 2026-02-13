//
//  UndergroundGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class UndergroundGameState: GridGameState<UndergroundGameMove> {
    var game: UndergroundGame {
        get { getGame() as! UndergroundGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { UndergroundDocument.sharedInstance }
    var objArray = [UndergroundObject]()
    var pos2state = [Position: AllowedObjectState]()

    override func copy() -> UndergroundGameState {
        let v = UndergroundGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: UndergroundGameState) -> UndergroundGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: UndergroundGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        updateIsSolved()
    }
    
    subscript(p: Position) -> UndergroundObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> UndergroundObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout UndergroundGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), game[p] == .empty, self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout UndergroundGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), game[p] == .empty else { return .invalid }
        let markerOption = MarkerOptions(rawValue: markerOption)
        let o = self[p]
        move.obj = switch o {
        case .empty: markerOption == .markerFirst ? .marker : .up
        case .up: .right
        case .right: .down
        case .down: .left
        case .left: markerOption == .markerLast ? .marker : .empty
        case .marker: markerOption == .markerFirst ? .up : .empty
        default: o
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 3/Puzzle Set 2/Underground

        Summary
        Subway entrances

        Description
        1. Each neighbourhood contains one entrance to the Underground.
        2. For each entrance there is a corresponding entrance in a different neighbourhood.
        3. The arrows of two corresponding entrances must point to each other.
        4. Between two corresponding entrances there cannot be any other entrance.
        5. Two corresponding entrances cannot be in adjacent neighbourhood, i.e.
           there must be at least one neighbourhood between them.
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        let nUp = UndergroundObject.up.rawValue
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                if self[p] == .forbidden {
                    self[p] = .empty
                }
                pos2state[p] = .normal
            }
        }
        // 1. Each neighbourhood contains one entrance to the Underground.
        for area in game.areas {
            let rng = area.filter { self[$0].rawValue >= nUp }
            if rng.count != 1 {
                isSolved = false
                for p in rng { pos2state[p] = .error }
            }
            guard allowedObjectsOnly && !rng.isEmpty else {continue}
            area.filter { self[$0] == .empty }.forEach {
                self[$0] = .forbidden
            }
        }
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let d = self[p].rawValue - nUp
                guard d >= 0 else {continue}
                let n1 = game.pos2area[p]!
                let os = UndergroundGame.offset[d]
                var p2 = p + os
                var rng = [Position]()
                var s: AllowedObjectState = .error
                while isValid(p: p2) {
                    let d2 = self[p2].rawValue - nUp
                    if d2 < 0 {
                        rng.append(p2)
                        p2 += os
                    } else {
                        // 2. For each entrance there is a corresponding entrance in a different neighbourhood.
                        // 3. The arrows of two corresponding entrances must point to each other.
                        // 4. Between two corresponding entrances there cannot be any other entrance.
                        // 5. Two corresponding entrances cannot be in adjacent neighbourhood, i.e.
                        //    there must be at least one neighbourhood between them.
                        let n2 = game.pos2area[p2]!
                        if n2 != n1 && rng.contains(where: {
                            let n3 = game.pos2area[$0]!
                            return n3 != n1 && n3 != n2
                        }) && (d + 2) % 4 == d2 { s = .normal }
                        break
                    }
                }
                if s == .error { isSolved = false }
                pos2state[p] = s
                guard allowedObjectsOnly && s == .normal else {continue}
                rng.filter { self[$0] == .empty }.forEach {
                    self[$0] = .forbidden
                }
            }
        }
    }
}
