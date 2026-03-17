//
//  DesertDunesGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class DesertDunesGameState: GridGameState<DesertDunesGameMove> {
    var game: DesertDunesGame {
        get { getGame() as! DesertDunesGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { DesertDunesDocument.sharedInstance }
    var objArray = [DesertDunesObject]()
    var pos2stateHint = [Position: HintState]()
    var pos2stateAllowed = [Position: AllowedObjectState]()
    var invalid2x2Squares = [Position]()
    
    override func copy() -> DesertDunesGameState {
        let v = DesertDunesGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: DesertDunesGameState) -> DesertDunesGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: DesertDunesGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<DesertDunesObject>(repeating: .empty, count: rows * cols)
        for p in game.pos2hint.keys {
            self[p] = .hint
        }
        updateIsSolved()
    }
    
    subscript(p: Position) -> DesertDunesObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> DesertDunesObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout DesertDunesGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && self[p] != .hint && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout DesertDunesGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && self[p] != .hint else { return .invalid }
        let markerOption = MarkerOptions(rawValue: markerOption)
        let o = self[p]
        move.obj = switch o {
        case .empty: markerOption == .markerFirst ? .marker : .dune
        case .dune: markerOption == .markerLast ? .marker : .empty
        case .marker: markerOption == .markerFirst ? .dune : .empty
        default: o
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games/Puzzle Set 17/Desert Dunes

        Summary
        Hide and seek in the desert

        Description
        1. Put some dunes on the desert so that each Oasis dweller can reach the
           number of Oases marked on it.
        2. The desert among dunes (including oases) should be all connected
           horizontally or vertically.
        3. Dwellers can move horizontally or vertically.
        4. Dunes cannot touch each other horizontally or vertically.
        5. No area of desert of 2x2 should be empty of Dunes.
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                if self[r, c] == .forbidden {
                    self[r, c] = .empty
                }
            }
        }
        // 5. No area of desert of 2x2 should be empty of Dunes.
        invalid2x2Squares.removeAll()
        for r in 0..<rows - 1 {
            for c in 0..<cols - 1 {
                let p = Position(r, c)
                let isEmptyOfDunes = DesertDunesGame.offset2.map { p + $0 }.allSatisfy { self[$0] != .dune }
                if isEmptyOfDunes { invalid2x2Squares.append(p + Position.SouthEast); isSolved = false }
            }
        }
        // 4. Dunes cannot touch each other horizontally or vertically.
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                guard self[p] == .dune else {continue}
                pos2stateAllowed[p] = .normal
                for os in DesertDunesGame.offset {
                    let p2 = p + os
                    guard isValid(p: p2) else {continue}
                    switch self[p2] {
                    case .dune:
                        isSolved = false
                        pos2stateAllowed[p] = .error
                    case .empty:
                        if allowedObjectsOnly { self[p2] = .forbidden }
                    default:
                        break
                    }
                }
            }
        }
        // 2. The desert among dunes (including oases) should be all connected
        //    horizontally or vertically.
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                guard self[p] != .dune else {continue}
                pos2node[p] = g.addNode(p.description)
            }
        }
        for (p, node) in pos2node {
            for os in DesertDunesGame.offset {
                let p2 = p + os
                if let node2 = pos2node[p2] { g.addEdge(node, neighbor: node2) }
            }
        }
        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
        if nodesExplored.count != pos2node.count { isSolved = false }
        for (p, _) in game.pos2hint {
            pos2node[p]!.neighbors = []
        }
        for node in g.nodes { node.visited = false }
        // 1. Put some dunes on the desert so that each Oasis dweller can reach the
        //    number of Oases marked on it.
        for (p, n2) in game.pos2hint {
            var hints = Set<Position>()
            // 3. Dwellers can move horizontally or vertically.
            DesertDunesGame.offset.map { p + $0 }
                .filter { isValid(p: $0) && self[$0] != .dune }
                .forEach { g.addEdge(pos2node[p]!, neighbor: pos2node[$0]!) }
            let nodesExplored = breadthFirstSearch(g, source: pos2node[p]!)
            pos2node[p]!.neighbors = []
            pos2node
                .filter { nodesExplored.contains($0.1.label) && self[$0.0] == .hint }
                .map { $0.0 }.forEach { hints.insert($0) }
            hints.remove(p)
            let n1 = hints.count
            let s: HintState = n1 > n2 ? .normal : n1 == n2 ? .complete : .error
            pos2stateHint[p] = s
            if s != .complete { isSolved = false }
            for node in g.nodes { node.visited = false }
        }
    }
}
