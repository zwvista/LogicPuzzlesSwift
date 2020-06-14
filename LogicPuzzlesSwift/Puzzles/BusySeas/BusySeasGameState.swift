//
//  BusySeasGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class BusySeasGameState: GridGameState<BusySeasGame, BusySeasGameMove> {
    override var gameDocument: GameDocumentBase { BusySeasDocument.sharedInstance }
    var objArray = [BusySeasObject]()
    
    override func copy() -> BusySeasGameState {
        let v = BusySeasGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: BusySeasGameState) -> BusySeasGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: BusySeasGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<BusySeasObject>(repeating: .empty, count: rows * cols)
        for p in game.pos2hint.keys {
            self[p] = .hint(state: .normal)
        }
        updateIsSolved()
    }
    
    subscript(p: Position) -> BusySeasObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> BusySeasObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout BusySeasGameMove) -> Bool {
        let p = move.p
        let (o1, o2) = (self[p], move.obj)
        if case .hint = o1 { return false }
        guard String(describing: o1) != String(describing: o2) else { return false }
        self[p] = o2
        updateIsSolved()
        return true
    }
    
    override func switchObject(move: inout BusySeasGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: BusySeasObject) -> BusySeasObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .lighthouse(state: .normal)
            case .lighthouse:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .lighthouse(state: .normal) : .empty
            default:
                return o
            }
        }
        move.obj = f(o: self[move.p])
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 14/Busy Seas

        Summary
        More seafaring puzzles

        Description
        1. You are at sea and you need to find the lighthouses and light the boats.
        2. Each boat has a number on it that tells you how many lighthouses are lighting it.
        3. A lighthouse lights all the tiles horizontally and vertically. Its
           light is stopped by the first boat it meets.
        4. Lighthouses can touch boats and other lighthouses.
    */
    private func updateIsSolved() {
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                switch self[p] {
                case .lighthouse:
                    self[p] = .lighthouse(state: .normal)
                case .forbidden:
                    self[p] = .empty
                default:
                    break
                }
            }
        }
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                func hasLightedBoat() -> Bool {
                    for os in BusySeasGame.offset {
                        var p2 = p + os
                        while game.isValid(p: p2) {
                            if case .hint = self[p2] { return true }
                            p2 += os
                        }
                    }
                    return false
                }
                if case let .lighthouse(state) = self[p] {
                    let s: AllowedObjectState = state == .normal && hasLightedBoat() ? .normal : .error
                    self[p] = .lighthouse(state: s)
                    if s == .error { isSolved = false }
                }
            }
        }
        // 3. A lighthouse lights all the tiles horizontally and vertically.
        for (p, n2) in game.pos2hint {
            var nums = [0, 0, 0, 0]
            var rng = [Position]()
            next: for i in 0..<4 {
                let os = BusySeasGame.offset[i]
                var p2 = p + os
                while game.isValid(p: p2) {
                    switch self[p2] {
                    case .hint:
                        // 3. A lighthouse's light is stopped by the first boat it meets.
                        continue next
                    case .empty:
                        rng.append(p2)
                    case .lighthouse:
                        nums[i] += 1
                    default:
                        break
                    }
                    p2 += os
                }
            }
            let n1 = nums.reduce(0, +)
            // 2. Each boat has a number on it that tells you how many lighthouses are lighting it.
            let s: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            self[p] = .hint(state: s)
            if s != .complete {
                isSolved = false
            } else {
                for p2 in rng {
                    self[p2] = .forbidden
                }
            }
        }
    }
}
