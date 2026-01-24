//
//  VeniceGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class VeniceGameState: GridGameState<VeniceGameMove> {
    var game: VeniceGame {
        get { getGame() as! VeniceGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { VeniceDocument.sharedInstance }
    var objArray = [VeniceObject]()
    
    override func copy() -> VeniceGameState {
        let v = VeniceGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: VeniceGameState) -> VeniceGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: VeniceGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<VeniceObject>(repeating: .empty, count: rows * cols)
        for p in game.pos2hint.keys {
            self[p] = .hint()
        }
        updateIsSolved()
    }
    
    subscript(p: Position) -> VeniceObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> VeniceObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout VeniceGameMove) -> GameOperationType {
        let p = move.p
        let (o1, o2) = (self[p], move.obj)
        if case .hint = o1 { return .invalid }
        guard String(describing: o1) != String(describing: o2) else { return .invalid }
        self[p] = o2
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout VeniceGameMove) -> GameOperationType {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: VeniceObject) -> VeniceObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .tower()
            case .tower:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .tower() : .empty
            default:
                return o
            }
        }
        move.obj = f(o: self[move.p])
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 3/Puzzle Set 2/Venice

        Summary
        Gondolas and Canals

        Description
        1. Each number identifies a house in Venice.
        2. The number on it tells you how many tiles of Canal that house sees,
           horizontally and vertically in the four directions, up to the next empty cell.
        3. The Canal forms a single connected area which cannot contain a 2x2 area
           (like a Nurikabe).
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
                    self[p] = .tower()
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
                    for os in VeniceGame.offset {
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
                let os = VeniceGame.offset[i]
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
            for os in VeniceGame.offset {
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
