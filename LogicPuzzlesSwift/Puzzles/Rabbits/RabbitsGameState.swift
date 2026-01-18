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
            self[p] = .hint(state: .normal)
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
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: RabbitsObject) -> RabbitsObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .tower(state: .normal)
            case .tower:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .tower(state: .normal) : .empty
            default:
                return o
            }
        }
        move.obj = f(o: self[move.p])
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
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                switch self[p] {
                case .tower:
                    self[p] = .tower(state: .normal)
                case .forbidden:
                    self[p] = .empty
                    fallthrough
                default:
                    pos2node[p] = g.addNode(p.description)
                }
            }
        }
        // 4. two Towers can't touch horizontally or vertically.
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                func hasNeighbor() -> Bool {
                    for os in RabbitsGame.offset {
                        let p2 = p + os
                        if isValid(p: p2), case .tower = self[p2] { return true }
                    }
                    return false
                }
                switch self[p] {
                case let .tower(state):
                    let s: AllowedObjectState = state == .normal && !hasNeighbor() ? .normal : .error
                    self[p] = .tower(state: s)
                    if s == .error { isSolved = false }
                case .empty, .marker:
                    guard allowedObjectsOnly && hasNeighbor() else {continue}
                    self[p] = .forbidden
                default:
                    break
                }
            }
        }
        // 2. The number tells you how many tiles that Sentinel can control (see) from
        // there vertically and horizontally. This includes the tile where he is
        // located.
        for (p, n2) in game.pos2hint {
            var nums = [0, 0, 0, 0]
            var rng = [Position]()
            next: for i in 0..<4 {
                let os = RabbitsGame.offset[i]
                var p2 = p + os
                while game.isValid(p: p2) {
                    switch self[p2] {
                    case .tower:
                        continue next
                    case .empty:
                        rng.append(p2)
                    default:
                        break
                    }
                    nums[i] += 1
                    p2 += os
                }
            }
            let n1 = nums[0] + nums[1] + nums[2] + nums[3] + 1
            let s: HintState = n1 > n2 ? .normal : n1 == n2 ? .complete : .error
            self[p] = .hint(state: s)
            if s != .complete {
                isSolved = false
            } else {
                for p2 in rng {
                    self[p2] = .forbidden
                }
            }
        }
        guard isSolved else {return}
        for (p, node) in pos2node {
            for os in RabbitsGame.offset {
                let p2 = p + os
                guard let node2 = pos2node[p2] else {continue}
                g.addEdge(node, neighbor: node2)
            }
        }
        // 4. There must be a single continuous Garden
        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
        if pos2node.count != nodesExplored.count { isSolved = false }
    }
}
