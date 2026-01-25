//
//  ArchipelagoGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class ArchipelagoGameState: GridGameState<ArchipelagoGameMove> {
    var game: ArchipelagoGame {
        get { getGame() as! ArchipelagoGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { ArchipelagoDocument.sharedInstance }
    var objArray = [ArchipelagoObject]()
    var pos2state = [Position: HintState]()
    var invalid2x2Squares = [Position]()

    override func copy() -> ArchipelagoGameState {
        let v = ArchipelagoGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: ArchipelagoGameState) -> ArchipelagoGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: ArchipelagoGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<ArchipelagoObject>(repeating: .empty, count: rows * cols)
        for p in game.pos2hint.keys {
            self[p] = .hint
        }
        updateIsSolved()
    }
    
    subscript(p: Position) -> ArchipelagoObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> ArchipelagoObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout ArchipelagoGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), game.pos2hint[p] == nil, String(describing: self[p]) != String(describing: move.obj) else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout ArchipelagoGameMove) -> GameOperationType {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: ArchipelagoObject) -> ArchipelagoObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .water
            case .water:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .water : .empty
            default:
                return o
            }
        }
        let p = move.p
        guard isValid(p: p), game.pos2hint[p] == nil else { return .invalid }
        move.obj = f(o: self[p])
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games/Puzzle Set 8/Archipelago

        Summary
        No bridges, just find the water

        Description
        1. Each number represents a rectangular island in the Archipelago.
        2. The number in itself identifies how many squares the island occupies.
        3. Islands can only touch each other diagonally and by touching they
           must form a network where no island is isolated from the others.
        4. In other words, every island must be touching another island diagonally
           and no group of islands must be separated from the others.
        5. Not all the islands you need to find are necessarily marked by numbers.
        6. Finally, no 2*2 square can be occupied by water only (just like Nurikabe).
    */
    private func updateIsSolved() {
        isSolved = true
        // 6. Finally, no 2*2 square can be occupied by water only (just like Nurikabe).
        invalid2x2Squares.removeAll()
        for r in 0..<rows - 1 {
            for c in 0..<cols - 1 {
                let p = Position(r, c)
                if ArchipelagoGame.offset2.map({ p + $0 }).allSatisfy({ self[$0] == .water }) {
                    invalid2x2Squares.append(p + Position.SouthEast); isSolved = false
                }
            }
        }
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                if case .water = self[p] {continue}
                pos2node[p] = g.addNode(p.description)
            }
        }
        for (p, node) in pos2node {
            for os in ArchipelagoGame.offset {
                let p2 = p + os
                guard let node2 = pos2node[p2] else {continue}
                g.addEdge(node, neighbor: node2)
            }
        }
        var areas = [[Position]]()
        var pos2area = [Position: Int]()
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let n1 = nodesExplored.count
            var r2 = 0, r1 = rows, c2 = 0, c1 = cols
            let area = pos2node.filter { nodesExplored.contains($0.1.label) }.map { $0.0 }
            pos2node = pos2node.filter { !nodesExplored.contains($0.1.label) }
            let n = areas.count
            for p in area {
                if r2 < p.row { r2 = p.row }
                if r1 > p.row { r1 = p.row }
                if c2 < p.col { c2 = p.col }
                if c1 > p.col { c1 = p.col }
                pos2area[p] = n
            }
            areas.append(area)
            let rs = r2 - r1 + 1, cs = c2 - c1 + 1
            // 1. Each number represents a rectangular island in the Archipelago.
            let isRect = rs * cs == n1
            let hints = area.filter { self[$0] == .hint }
            if hints.count > 1 {
                isSolved = false
                for p in hints { pos2state[p] = .normal }
            } else if hints.count == 1 {
                let p = hints.first!
                let n2 = game.pos2hint[p]!
                // 2. The number in itself identifies how many squares the island occupies.
                let s: HintState = !isRect || n1 > n2 ? .normal : n1 == n2 ? .complete : .error
                pos2state[p] = s
                if s != .complete { isSolved = false }
            }
        }
        guard isSolved else { return }
        // 3. Islands can only touch each other diagonally and by touching they
        //    must form a network where no island is isolated from the others.
        // 4. In other words, every island must be touching another island diagonally
        //    and no group of islands must be separated from the others.
        let g2 = Graph()
        for i in areas.indices {
            _ = g2.addNode(String(i))
        }
        for (i, area) in areas.enumerated() {
            var indexes = Set<Int>()
            for p in area {
                for os in ArchipelagoGame.offset3 {
                    guard let j = pos2area[p + os], j != i else {continue}
                    indexes.insert(j)
                }
            }
            if indexes.isEmpty { isSolved = false; return }
            for j in indexes { g2.addEdge(g2.nodes[i], neighbor: g2.nodes[j]) }
        }
        // 5. All the land tiles are connected horizontally or vertically.
        let nodesExplored = breadthFirstSearch(g2, source: g2.nodes.first!)
        if nodesExplored.count != g2.nodes.count { isSolved = false }
    }
}
