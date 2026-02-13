//
//  RabbitsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class RabbitsGameState: GridGameState<RabbitsGameMove> {
    var game: RabbitsGame {
        get { getGame() as! RabbitsGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { RabbitsDocument.sharedInstance }
    var objArray = [RabbitsObject]()
    
    override func copy() -> RabbitsGameState {
        let v = RabbitsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: RabbitsGameState) -> RabbitsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: RabbitsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<RabbitsObject>(repeating: .empty, count: rows * cols)
        for p in game.pos2hint.keys {
            self[p] = .hint()
        }
        updateIsSolved()
    }
    
    subscript(p: Position) -> RabbitsObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> RabbitsObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout RabbitsGameMove) -> GameOperationType {
        let p = move.p
        let (o1, o2) = (self[p], move.obj)
        if case .hint = o1 { return .invalid }
        guard String(describing: o1) != String(describing: o2) else { return .invalid }
        self[p] = o2
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout RabbitsGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) else { return .invalid }
        let markerOption = MarkerOptions(rawValue: markerOption)
        let o = self[p]
        move.obj = switch o {
        case .empty: markerOption == .markerFirst ? .marker : .rabbit()
        case .rabbit: .tree()
        case .tree: markerOption == .markerLast ? .marker : .empty
        case .marker: markerOption == .markerFirst ? .rabbit() : .empty
        default: o
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 3/Puzzle Set 3/Rabbits

        Summary
        Rabbit 'n' Seek

        Description
        1. The board represents a lawn where Rabbits are playing Hide 'n' Seek,
           behind Trees.
        2. Each number tells you how many Rabbits can be seen from that tile,
           in an horizontal and vertical line.
        3. Tree hide Rabbits, numbers don't.
        4. Each row and column has exactly one Tree and one Rabbit.
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                switch self[p] {
                case .rabbit:
                    self[p] = .rabbit()
                case .tree:
                    self[p] = .tree()
                case .forbidden:
                    self[p] = .empty
                default:
                    break
                }
            }
        }
        // 4. Each row and column has exactly one Tree and one Rabbit.
        func f(rng: [Position]) {
            let rngRabbit = rng.filter { self[$0].toString() == "rabbit" }
            if rngRabbit.count != 1 {
                isSolved = false
                for p in rngRabbit { self[p] = .rabbit(state: .error) }
            }
            let rngTree = rng.filter { self[$0].toString() == "tree" }
            if rngTree.count != 1 {
                isSolved = false
                for p in rngTree { self[p] = .tree(state: .error) }
            }
            guard allowedObjectsOnly && rngRabbit.count >= 1 && rngTree.count >= 1 else {return}
            let rngEmpty = rng.filter { self[$0].toString() == "empty" }
            for p in rngEmpty { self[p] = .forbidden }
        }
        for r in 0..<rows {
            let rng = (0..<cols).map { Position(r, $0) }
            f(rng: rng)
        }
        for c in 0..<cols {
            let rng = (0..<rows).map { Position($0, c) }
            f(rng: rng)
        }
        // 2. Each number tells you how many Rabbits can be seen from that tile,
        //    in an horizontal and vertical line.
        // 3. Tree hide Rabbits, numbers don't.
        for (p, n2) in game.pos2hint {
            var n1 = 0
            next: for os in RabbitsGame.offset {
                var p2 = p + os
                while isValid(p: p2) {
                    switch self[p2] {
                    case .rabbit: n1 += 1; continue next
                    case .tree: continue next
                    default: break
                    }
                    p2 += os
                }
            }
            let s: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            self[p] = .hint(state: s)
            if s != .complete { isSolved = false }
        }
    }
}
