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
        for (p, _) in game.pos2hint { self[p] = .hint() }
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
                let isFullOfWater = ArchipelagoGame.offset2.map { p + $0 }.allSatisfy { self[$0].toString() == "water" }
                if isFullOfWater { invalid2x2Squares.append(p + Position.SouthEast); isSolved = false }
            }
        }
        var g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                guard case .water = self[p] else {continue}
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
            if !(rs == cs && rs * cs == nodesExplored.count) {
                isSolved = false
                for p in area {
                    self[p] = .water(state: .error)
                }
            }
        }
        for (p, n2) in game.pos2hint {
            guard case let .hint(n, _) = self[p] else {continue}
            var n1 = 0
            for os in ArchipelagoGame.offset {
                guard let i = pos2area[p + os] else {continue}
                n1 += areas[i].count
            }
            // 3. A number tells you the total size of any waters orthogonally touching it,
            // while a question mark tells you that there is at least one water orthogonally
            // touching it.
            let s: HintState = n1 == 0 ? .normal : n1 == n2 || n2 == -1 ? .complete : .error
            self[p] = .hint(tiles: n, state: s)
            if s != .complete { isSolved = false }
        }
        g = Graph()
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
        // 5. All the land tiles are connected horizontally or vertically.
        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
        if nodesExplored.count != pos2node.count { isSolved = false }
    }
}
