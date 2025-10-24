//
//  ParkLakesGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class ParkLakesGameState: GridGameState<ParkLakesGameMove> {
    var game: ParkLakesGame {
        get { getGame() as! ParkLakesGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { ParkLakesDocument.sharedInstance }
    var objArray = [ParkLakesObject]()
    
    override func copy() -> ParkLakesGameState {
        let v = ParkLakesGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: ParkLakesGameState) -> ParkLakesGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: ParkLakesGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<ParkLakesObject>(repeating: .empty, count: rows * cols)
        for (p, n) in game.pos2hint {
            self[p] = .hint(tiles: n, state: .normal)
        }
        updateIsSolved()
    }
    
    subscript(p: Position) -> ParkLakesObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> ParkLakesObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout ParkLakesGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), game.pos2hint[p] == nil, String(describing: self[p]) != String(describing: move.obj) else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout ParkLakesGameMove) -> GameOperationType {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: ParkLakesObject) -> ParkLakesObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .lake(state: .normal)
            case .lake:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .lake(state: .normal) : .empty
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
        iOS Game: Logic Games/Puzzle Set 15/Park Lakes

        Summary
        Find the Lakes

        Description
        1. The board represents a park, where there are some hidden lakes, all square
           in shape.
        2. You have to find the lakes with the aid of hints, knowing that:
        3. A number tells you the total size of any lakes orthogonally touching it,
           while a question mark tells you that there is at least one lake orthogonally
           touching it.
        4. Lakes aren't on tiles with numbers or question marks.
        5. All the land tiles are connected horizontally or vertically.
    */
    private func updateIsSolved() {
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                switch self[p] {
                case .lake:
                    self[p] = .lake(state: .normal)
                case let .hint(tiles, _):
                    self[p] = .hint(tiles: tiles, state: .normal)
                default:
                    break
                }
            }
        }
        var g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                guard case .lake = self[p] else {continue}
                pos2node[p] = g.addNode(p.description)
            }
        }
        for (p, node) in pos2node {
            for os in ParkLakesGame.offset {
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
                    self[p] = .lake(state: .error)
                }
            }
        }
        for (p, n2) in game.pos2hint {
            guard case let .hint(n, _) = self[p] else {continue}
            var n1 = 0
            for os in ParkLakesGame.offset {
                guard let i = pos2area[p + os] else {continue}
                n1 += areas[i].count
            }
            // 3. A number tells you the total size of any lakes orthogonally touching it,
            // while a question mark tells you that there is at least one lake orthogonally
            // touching it.
            let s: HintState = n1 == 0 ? .normal : n1 == n2 || n2 == -1 ? .complete : .error
            self[p] = .hint(tiles: n, state: s)
            if s != .complete { isSolved = false }
        }
        g = Graph()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                if case .lake = self[p] {continue}
                pos2node[p] = g.addNode(p.description)
            }
        }
        for (p, node) in pos2node {
            for os in ParkLakesGame.offset {
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
